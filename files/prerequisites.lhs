\documentclass[10pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[british]{babel}
\usepackage{geometry}
\usepackage{verbatim}
\newenvironment{code}{\footnotesize\verbatim}{\endverbatim\normalsize}
\usepackage[colorlinks=true,linkcolor=blue]{hyperref}
\usepackage{charter} % Use the Charter font for the document text
\usepackage[inline]{enumitem}
\setlist[enumerate,1]{label={\color{red}\textit{\arabic*)}}}
\usepackage{microtype}

\title{Prerequisites: Basic Functional Programming in Haskell}
\date{}
\author{Liang-Ting Chen}


\begin{document}
\maketitle 

The first part of the following questions requires basic understanding of how to
define a function in Haskell. The second part is a recursive
function using techniques you should have learned from the first 4
chapters of \href{http://learnyouahaskell.com}{\emph{Learn You a Haskell for Great Good!}}. 

Please check your answer using the interactive interpreter \texttt{ghci} before
submission. If you are not familiar with the command-line interface, please
read \href{http://book.realworldhaskell.org/read/getting-started.html}{the
first chapter} of \emph{Real World Haskell}. 


\begin{enumerate}
\item Define a function called \texttt{myFst} which takes a tuple and returns the first component. 
\begin{code}
myFst :: (a, b) -> a
myFst = undefined
\end{code}

  \item Define a function \texttt{myOdd} which determines if the input is an odd
  number or not. Hint: You may use \texttt{mod} (what is this?). 
\begin{code}
myOdd :: Int -> Bool
myOdd = undefined
\end{code}

  \item Consider the following function.
\begin{code}
qs :: Ord a => [a] -> [a]
qs []     = []
qs (x:xs) = qs ys ++ [x] ++ qs zs 
  where
    ys = [ y | y <- xs, y <= x ]
    zs = [ z | z <- xs, x < z  ]
\end{code}
Please answer the following questions concisely either in plain English or Chinese. 
    \begin{enumerate}
      \item What is \texttt{Ord}? What does the type of \texttt{qs} mean?
      \item What is the type of \texttt{(++)}? What does it do? 
      \item What are the elements of \texttt{ys} and \texttt{zs}, respectively? 
      \item What does the function \texttt{qs} do? Hint: If you are not
familiar with recursive functions (functions which are defined in terms of
themselves), run \texttt{qs} on some lists (e.g., \texttt{[2, 1, 4, 3, 5]}) and
make a guess. 

      \item Please re-write the function \texttt{qs} above and call it
  \texttt{qs'} using \textbf{let} expression and \textbf{case} expression
  instead of \textbf{where} clause and pattern matching. 
    \end{enumerate}
\end{enumerate}

\end{document}
