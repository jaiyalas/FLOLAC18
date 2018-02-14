{-# LANGUAGE OverloadedStrings #-}

import Control.Applicative ((<$>))
import Data.Monoid         ((<>))
import qualified Data.Set as Set
import Text.Pandoc.Options
import Hakyll

import Control.Applicative
import Control.Monad          (forM,mapM)
import Data.List              (sortBy)
import Data.Ord               (comparing)
import Data.Time.Format       (defaultTimeLocale)
import Data.Time.LocalTime    (utcToLocalTime,
                               hoursToTimeZone,
                               utcToZonedTime,
                               LocalTime)
import Data.Time.Format       (formatTime)

summarySize = 3

main :: IO ()
main = hakyll $ do
    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler
    match "js/**" $ do
        route   idRoute
        compile copyFileCompiler
    match "css/**" $ do
        route   idRoute
        compile compressCssCompiler
    match "img/*" $ do
        route   idRoute
        compile copyFileCompiler
    match "templates/*" $ compile templateCompiler
    --
    {- ################################### -}
    -- Tags handling and generating
    {- ################################### -}
    tags <- buildTags "content/posts/*" $ fromCapture "tags/*.html"
    tagsRules tags $ \tag pattern -> do
        let tagCtx = constField "tagName" tag <> initCtx ("Tag - "++tag)
        route idRoute
        compile $ do
            postsTagged tags pattern recentFirst
                >>= makeItem
                >>= loadAndApplyTemplate "templates/postsWithTag.html" tagCtx
                >>= loadAndApplyTemplate "templates/default.html"      tagCtx
                >>= relativizeUrls
    create ["tags.html"] $ do
        route idRoute
        compile $ do
            renderTagList tags
                >>= makeItem
                >>= loadAndApplyTemplate "templates/tagCloud.html" (initCtx "Tags")
                >>= loadAndApplyTemplate "templates/default.html"  (initCtx "Tags")
                >>= relativizeUrls
    {- ################################### -}
    -- Generate posts (HTML) by parsing posts (*.md)
    {- ################################### -}
    match "content/posts/*" $ version "toc" $
        compile $ customPandocCompiler
    match "content/posts/*" $ do
        route $ setExtension "html"
        compile $ customPandocCompiler_simple
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    (taggedPostCtx tags)
            >>= loadAndApplyTemplate "templates/default.html" (initCtx "Post")
            >>= relativizeUrls
    {- ################################### -}
    -- Generate archive page
    {- ################################### -}
    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll ("content/posts/*" .&&. hasNoVersion)
            let archiveCtx =
                    listField "posts" (taggedPostCtx tags) (return posts) <> (initCtx "Archive")
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls
    {- ################################### -}
    -- Create static pages
    {- ################################### -}
    match "content/static/about.md" $ do
        route $ routeStatic2Root `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple -- pandocCompiler'
            >>= loadAndApplyTemplate "templates/staticPageNoToC.html"   (initCtx "About")
            >>= loadAndApplyTemplate "templates/default.html" (initCtx "About")
            >>= relativizeUrls
    match "content/static/index.html" $ do
        route routeStatic2Root
        compile $ do
            posts <- fmap (take 3) . recentFirst =<< loadAllSnapshots ("content/posts/*" .&&. hasNoVersion) "content"
            let indexCtx = listField "posts" postCtx (return posts) <> (initCtx "Home")
            getResourceBody
                >>= applyAsTemplate                               indexCtx
                >>= loadAndApplyTemplate "templates/default.html" (initCtx "Home")
                >>= relativizeUrls
    -- #########  for slides ######### --
    match "slides/img/*" $ do
        route   idRoute
        compile copyFileCompiler
    match "slides/*" $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= relativizeUrls
    match "content/static/slides.md" $ do
        route $ routeStatic2Root `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple -- pandocCompiler'
            >>= loadAndApplyTemplate "templates/staticPageNoToC.html"   (initCtx "Slides")
            >>= loadAndApplyTemplate "templates/default.html" (initCtx "Slides")
            >>= relativizeUrls
    -- #########  for "From Cloud to Dirt" franchise ######### --
    match "content/static/*" $ version "toc" $
        compile $ customPandocCompiler
    --
    match "content/static/c2d.md" $ do
        route $ routeStatic2Root `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple -- pandocCompiler'
            >>= loadAndApplyTemplate "templates/staticPage.html" (initCtxWithToC "From Cloud to Dirt")
            >>= loadAndApplyTemplate "templates/default.html"    (initCtx "From Cloud to Dirt")
            >>= relativizeUrls
    --
    match "content/static/agdaNotes.md" $ do
        route $ routeStatic2Root `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple -- pandocCompiler'
            >>= loadAndApplyTemplate "templates/staticPage.html" (initCtxWithToC "Agda Notes")
            >>= loadAndApplyTemplate "templates/default.html"    (initCtx "Agda Notes")
            >>= relativizeUrls
    --
    match "content/static/haskellNotes.md" $ do
        route $ routeStatic2Root `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple -- pandocCompiler'
            >>= loadAndApplyTemplate "templates/staticPage.html" (initCtxWithToC "Haskell Notes")
            >>= loadAndApplyTemplate "templates/default.html"    (initCtx "Haskell Notes")
            >>= relativizeUrls

--------------------------------------------------------------------------------

initCtx :: String -> Context String
initCtx str = constField "blog_title" "Jaiyalas' Notes on Computing Science" <>
              constField "page_title" str         <>
              defaultContext

initCtxWithToC :: String -> Context String
initCtxWithToC str =
    field "toc" (\item -> loadBody ((itemIdentifier item) {identifierVersion = Just "toc"})) <>
    initCtx str

postCtx :: Context String
postCtx =
    teaserField "teaser" "content"           <>
    modificationTimeField "mdate" "%d %b %Y" <>
    modificationTimeField "mtime" "%H:%M"    <>
    dateField  "date" "%d %b %Y"             <>
    initCtxWithToC "Post"

taggedPostCtx :: Tags -> Context String
taggedPostCtx tags = tagsField "tags" tags <> postCtx

postsTagged :: Tags -> Pattern -> ([Item String] -> Compiler [Item String]) -> Compiler String
postsTagged tags pattern sortFilter = do
    template <- loadBody "templates/post-item.html"
    posts <- sortFilter =<< loadAll pattern
    applyTemplateList template postCtx posts

routeStatic2Root :: Routes
routeStatic2Root = gsubRoute "content/static/" $ const ""
routeStatic2Root' :: Routes
routeStatic2Root' = gsubRoute "content/" $ const ""

extensions :: Set.Set Extension
extensions = Set.fromList [Ext_inline_notes, Ext_tex_math_dollars]

customPandocCompiler_simple :: Compiler (Item String)
customPandocCompiler_simple =
    pandocCompilerWith
        pandocMathReaderOptions
        pandocWriterOptions_s

customPandocCompiler :: Compiler (Item String)
customPandocCompiler =
    pandocCompilerWith
        pandocMathReaderOptions
        pandocWriterOptions

pandocMathReaderOptions :: ReaderOptions
pandocMathReaderOptions = defaultHakyllReaderOptions
    { readerExtensions = Set.union (readerExtensions defaultHakyllReaderOptions) extensions
    }

pandocWriterOptions_s :: WriterOptions
pandocWriterOptions_s  = defaultHakyllWriterOptions
    { writerExtensions = Set.union (writerExtensions defaultHakyllWriterOptions) extensions
    , writerHTMLMathMethod = MathJax ""
    }

pandocWriterOptions :: WriterOptions
pandocWriterOptions = defaultHakyllWriterOptions
    { writerExtensions = Set.union (writerExtensions defaultHakyllWriterOptions) extensions
    , writerHTMLMathMethod = MathJax ""
    --
    , writerTableOfContents = True
    , writerTemplate = "$toc$"
    , writerStandalone = True
    , writerTOCDepth = 2
    }
