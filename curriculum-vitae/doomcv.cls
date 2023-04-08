\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{doomcv}[<2022\-02\-22> More advanved LaTeX class for composing CVs.]

\newif\ifdoomcv@german
\newif\ifdoomcv@english

\DeclareOption{german}{\doomcv@germantrue}
\DeclareOption{english}{\doomcv@englishtrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[10pt,a4paper]{article}

\ifdoomcv@german
    \RequirePackage[ngerman]{babel}
    \input{cv_lang_german.tex}
\else
    \usepackage[english]{babel}
    \input{cv_lang_english.tex}
\fi

\RequirePackage[utf8]{inputenc}
\RequirePackage{fontawesome}
\RequirePackage{xcolor}
\RequirePackage{enumitem}
\RequirePackage{tabularx}
\RequirePackage{geometry}
\RequirePackage{hyperref}
\RequirePackage{tikz}
\RequirePackage[absolute]{textpos}
\RequirePackage{multicol}
\RequirePackage{parskip}
\RequirePackage{adjustbox}
\RequirePackage{calc}
\RequirePackage{pifont}

\usetikzlibrary{calc,shapes,arrows.meta,positioning,backgrounds}

\definecolor{dodgerblue}{RGB}{30,144,255}
\definecolor{navyblue}{RGB}{0,70,129}


\hypersetup{
    colorlinks,
    linkcolor={red!50!black},
    citecolor={navyblue!50!black},
    urlcolor={navyblue!80!black}
}

\geometry{a4paper,
    left=5mm, right=5mm,
    top=20mm, bottom=20mm
}
\graphicspath{{./img/}}
\pagestyle{empty}

\newlength{\sidebarwidth}
\newlength{\mainpanewidth}
\setlength{\sidebarwidth}{0.35\paperwidth}
\setlength{\mainpanewidth}{0.6\paperwidth}

%region Two-Column Environments
\newenvironment{sidebar}{
    \begin{textblock*}{\sidebarwidth}(5mm,0mm)
        \begin{tikzpicture}[remember picture,overlay]
            \begin{scope}[on background layer]
                \node [
                    rectangle, fill=navyblue, anchor=north west, 
                    minimum width=\sidebarwidth, minimum height=\paperheight
                ] (box) at ($(current page.north west)+(5mm,0mm)$) {};
            \end{scope}
        \end{tikzpicture}
        \begin{minipage}[t][\paperheight]{\sidebarwidth}
            \vspace{10mm}
            \sffamily\large\color{white}
            \vspace*{\dimexpr0.1\paperheight}
            \begin{center}
}{
            \end{center}
            \vfill\null
        \end{minipage}
    \end{textblock*}
    \strut
}

\newenvironment{mainpane}{
    \begin{textblock*}{\mainpanewidth}(1.15\sidebarwidth,0mm)
        \begin{minipage}[t][\paperheight]{\mainpanewidth}
            \vspace{10mm}
            \sffamily\large\color{black}
            \vspace*{\dimexpr0.1\paperheight}
}{
            \vfill\null
        \end{minipage}
    \end{textblock*}
    \strut
}
%endregion

%region Timeline
\newenvironment{timeline}[1]{
    \begin{tikzpicture}[
        timeline/.style={draw, -{Stealth[length=3mm]}, line width=0.4mm},
        eventline/.style={line width=2mm},
        date/.style={anchor=east, font=\sffamily\small},
        event/.style={anchor=west, font=\sffamily\small, align=left}
    ]
        \draw[timeline] (0,0) -- (0,#1);
}{ \end{tikzpicture} }

\newcommand{\timelineentry}[3]{
    \draw[eventline] (#1) node[date] {#2};
    \draw (#1) node[circle,fill,inner sep=1.5pt] {} -- +(0.2,0) node[event] {#3};
}
%endregion

%region CV Sections
\newcommand{\cvpanesectionstyle}[1]{\sffamily\Huge\textbf{#1}}
\newcommand{\cvpanesection}[1]{
    \vspace{1em}
    \textcolor{navyblue}{\cvpanesectionstyle{#1}}
    \vspace{0.5em} 
    \rule{\mainpanewidth-20pt-\widthof{\cvpanesectionstyle{#1}}}{0.5pt}
    \vspace{0.5em}\\
}

\newcommand{\cvsection}[1]{
    \vspace{1em}
    \textcolor{navyblue}{\cvpanesectionstyle{#1}}
    \vspace{0.5em}
    \hrule height 0.5pt
    \vspace{0.5em}
}

\newcommand{\cvpanesubsectionstyle}[1]{\sffamily\LARGE\textbf{#1}}
\newcommand{\cvpanesubsection}[1]{
    \vspace{0.75em}
    \textcolor{navyblue}{\cvpanesubsectionstyle{#1}}
    \vspace{0.25em} 
    \rule{\mainpanewidth-20pt-\widthof{\cvpanesubsectionstyle{#1}}}{0.3pt}
    \vspace{0.25em}\\
}
%endregion

%region Education
\newenvironment{education}[1]{
    \cvpanesection{\doomcvEducation}
    \begin{timeline}{#1}
}{\end{timeline}}

\newcommand{\educationentry}[4]{
    \timelineentry{0,#1}{\large #2}{\large #3 - #4}
}
%endregion
