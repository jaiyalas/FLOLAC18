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
    match "css/**" $ do
        route   idRoute
        compile compressCssCompiler
    match "img/*" $ do
        route   idRoute
        compile copyFileCompiler
    match "files/*" $ do
        route   idRoute
        compile copyFileCompiler
    match "template/*" $ compile templateCompiler
    --
    {- ################################### -}
    -- Generate posts (HTML) by parsing posts (*.md)
    {- ################################### -}
    match "content/courses/*" $ do
        route $ routeStatic2Root' `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple
            >>= loadAndApplyTemplate "template/post.html"      defaultContext
            >>= loadAndApplyTemplate "template/post-head.html" defaultContext
            >>= loadAndApplyTemplate "template/default.html"   defaultContext
            >>= relativizeUrls
    {- ################################### -}
    -- Create static pages
    {- ################################### -}
    match "content/timeline.md" $ do
        route $ routeStatic2Root' `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple
            >>= loadAndApplyTemplate "template/post.html"    defaultContext
            >>= loadAndApplyTemplate "template/header.html"  defaultContext
            >>= loadAndApplyTemplate "template/default.html" (initCtx "timeline")
            >>= relativizeUrls
    match "content/register.md" $ do
        route $ routeStatic2Root' `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple
            >>= loadAndApplyTemplate "template/post.html"    defaultContext
            >>= loadAndApplyTemplate "template/header.html"  defaultContext
            >>= loadAndApplyTemplate "template/default.html" (initCtx "register")
            >>= relativizeUrls
    match "content/prep.md" $ do
        route $ routeStatic2Root' `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple
            >>= loadAndApplyTemplate "template/post.html"    defaultContext
            >>= loadAndApplyTemplate "template/header.html"  defaultContext
            >>= loadAndApplyTemplate "template/default.html" (initCtx "register")
            >>= relativizeUrls
    match "content/index.md" $ do
        route $ routeStatic2Root' `composeRoutes` setExtension "html"
        compile $ customPandocCompiler_simple
            >>= loadAndApplyTemplate "template/post.html"    defaultContext
            >>= loadAndApplyTemplate "template/header.html"  defaultContext
            >>= loadAndApplyTemplate "template/default.html" (initCtx "Home")
            >>= relativizeUrls
    match "content/courses.html" $ do
        route routeStatic2Root'
        compile $ do
           getResourceBody
               >>= loadAndApplyTemplate "template/header.html"  defaultContext
               >>= loadAndApplyTemplate "template/default.html" (initCtx "courses")
               >>= relativizeUrls

    -- match "content/index.html" $ do
    --     route routeStatic2Root'
    --     compile $ do
    --         getResourceBody
    --             >>= loadAndApplyTemplate "template/header.html"  defaultContext
    --             >>= loadAndApplyTemplate "template/default.html" (initCtx "Home")
    --             >>= relativizeUrls
--------------------------------------------------------------------------------

initCtx :: String -> Context String
initCtx str = defaultContext

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

pandocWriterOptions_s :: WriterOptions
pandocWriterOptions_s  = defaultHakyllWriterOptions

pandocWriterOptions :: WriterOptions
pandocWriterOptions = defaultHakyllWriterOptions
