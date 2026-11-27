[![build](https://github.com/thomasWeise/bookbase/actions/workflows/build.yaml/badge.svg)](https://github.com/thomasWeise/bookbase/actions/workflows/build.yml)
[![https://thomasweise.github.io](https://shields.io/badge/home-thomasweise.github.io-009000)](https://thomasweise.github.io)

# bookbase

## 1. Introduction

These are the shared files in my book and teaching material building projects.
The files, bibliography, and scripts in this repository are used by several of my writing and teaching projects, including:

- [Programming with Python](https://thomasweise.github.io/programmingWithPython)
- [Databases](https://thomasweise.github.io/databases)
- my [Talks](https://thomasweise.github.io/talks)

The repository offers LaTeX styles for books and slides&nbsp;(with background photos taken from our university), glossary support, my personal bibliography, scripts for compiling books and slides to PDF and to minify those PDFs, listings, support for including files from other `git` repositories&nbsp;(via [`texgit`](https://thomasweise.github.io/software/texgit)), support for Python code and virtual environments, and many more utilities.
These are all designed particularly as foundation for my personal projects, tailored to our uni, and so on.
However, there might be bits and pieces of code useful for others in here as well.


## 2. Usage
## 2.1. Mount as Git Submodule
The best way to use `bookbase` is to mount it into your `git` repository as submodule.
You can do this by entering your Git project's base directory and then executing:

```bash
git submodule add https://github.com/thomasWeise/bookbase
```

Then you can use all the scripts, bibliography, and styles from the package.
They will all be in the subfolder `bookbase` inside your own checked-out repository.

You can update the submodule to stay up-to-date.
If you change the files inside the submodule, you can also commit and push them from there.


### 2.2. Usage in GitHub Actions
You can use the `bookbase` build process inside a [GitHub Action](https://github.com/actions).
You would create a directory named `.github` and inside of that a directory called `workflows`.
Inside `.github/workflows`, you'd create the file `build.yaml` as follows:

<pre>
<code>name: publish</code>

<code>on:</code>
<code>  push:</code>
<code>    branches:</code>
<code>      - main</code>

<code>jobs:</code>
<code>  build:</code>
<code>    runs-on: ubuntu-latest</code>
<code>    steps:</code>
<code>      - uses: actions/checkout@v7.0.1</code>
<code>        with:</code>
<code>          submodules: true</code>
<code>      - uses: xu-cheng/texlive-action@v3</code>
<code>        with:</code>
<code>          scheme: full</code>
<code>          run: |</code>
<code>            apk add cargo gcc linux-headers musl-dev py3-pip python3 python3-dev rust</code>
<code>            MAKE_COMMAND</code>

<code>      - name: deploy documentation</code>
<code>        uses: JamesIves/github-pages-deploy-action@v4.8.0</code>
<code>        with:</code>
<code>          branch: gh-pages</code>
<code>          folder: /home/runner/work/REPO_NAME/REPO_NAME/website/</code>
<code>          single-commit: true</code>
</pre>

If you are building a book, you would replace `MAKE_COMMAND` with

```bash
./bookbase/scripts/bookMake.sh pdfFileBaseName bookTitle bookWebsiteBaseURL
```

If you are building slides, you would replace `MAKE_COMMAND` with


```bash
./bookbase/scripts/slidesMake.sh slidesMainTitle slidesWebsiteBaseURL
```

In either case, `REPO_NAME` is to be replaced with the repository name.


## 3. License
With the exceptions below, the files here are under the Attribution-NonCommercial-ShareAlike 4.0 International license (CC&nbsp;BY&#8209;NC&#8209;SA&nbsp;4.0), see [http://creativecommons.org/licenses/by-nc-sa/4.0/](http://creativecommons.org/licenses/by-nc-sa/4.0/) for a summary.

We statically include the [pdfsizeopt](https://github.com/pts/pdfsizeopt) tool in the [GitHub Repository](https://github.com/thomasWeise/programmingWithPython) of our books and slides.
We did use it during the book compiling and building processes in the past to compress the PDF files.
It is still contained for historical reasons, because it produces smaller PDFs at the expense of longer builds.
This tool is excluded from the license mentioned above.
It is under the GNU GENERAL PUBLIC LICENSE Version 2, June 1991 and the copyright belongs to its authors.


## 4. Contact
If you have any questions or suggestions, please contact
Prof.&nbsp;Dr.&nbsp;[Thomas Weise](https://thomasweise.github.io) (汤卫思教授)
of the School of Artificial Intelligence and Big Data ([人工智能与大数据学院](http://www.hfuu.edu.cn/aibd))
of [Hefei University](http://www.hfuu.edu.cn/english/) ([合肥大学](http://www.hfuu.edu.cn/)),
in Hefei, Anhui, China (中国安徽省合肥市)
via email to [tweise@hfuu.edu.cn](mailto:tweise@hfuu.edu.cn) with CC to [tweise@ustc.edu.cn](mailto:tweise@ustc.edu.cn).
