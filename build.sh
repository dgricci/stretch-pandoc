#!/bin/bash
  
## Dockerfile for a pandoc environment
# See https://hackage.haskell.org/packages/search?terms=pandoc

# Exit on any non-zero status.
trap 'exit' ERR
set -E

# install
export DEBIAN_FRONTEND=noninteractive
apt-get -qy update
apt-get -qy install \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-lang-french \
    texlive-font-utils \
    texlive-fonts-recommended \
    texlive-pictures \
    texlive-pstricks \
    texlive-xetex \
    zlib1g-dev \
    unzip
cabal update

cabal install \
    pandoc-${PANDOC_VERSION} \
    pandoc-include-code-1.3.0.0 \
    pandoc-placetable-0.5

# install pandoc globally to prevent : error: exec: "/root/.cabal/bin/pandoc": stat /root/.cabal/bin/pandoc: permission denied
# with cabal 2 --global is deprecated, so user-install: False has been set in /root/.cabal/config
# See dgricci/haskell

# removed pandoc-include package cause of :
#IncludeFilter.hs:71:53: error:
#    * Couldn't match type `[Char]' with `Data.Text.Internal.Text'
#      Expected type: Data.Text.Internal.Text
#        Actual type: String
#    * In the second argument of `readMarkdown', namely `content'
#      In the second argument of `($!)', namely `readMarkdown def content'
#      In the expression: return $! readMarkdown def content
#   |
#71 | ioReadMarkdown content = return $! readMarkdown def content
#   |                                                     ^^^^^^^
# work-around (worked in pandoc 2.1.3 not in 2.2.3.2) :
#echo "Compiling and Installing pandoc-include from https://github.com/steindani/pandoc-include.git, branch issueFixes ..."
#cd /root/.cabal/packages/hackage.haskell.org/
#mkdir -p pandoc-include
#cd pandoc-include
#git clone https://github.com/steindani/pandoc-include.git 0.0.2
#cd 0.0.2
#git checkout origin/issueFixes
#sed -i -e "s/0\.0\.1/0.0.2/" pandoc-include.cabal
#sed -i -e "s/^\(  Hs-Source-Dirs:     \)src/\1./" pandoc-include.cabal
#sed -i -e "s/^\({-# LANGUAGE BangPatterns\)\( #-}\)/\1, OverloadedStrings\2/" IncludeFilter.hs
#runghc Setup configure
#runghc Setup build
#runghc Setup install

# pandoc-plantuml-diagrams failed :
#[1 of 6] Compiling Text.Pandoc.PlantUML.Filter.Types ( src/Text/Pandoc/PlantUML/Filter/Types.hs, dist/build/Text/Pandoc/PlantUML/Filter/Types.o )
#[2 of 6] Compiling Text.Pandoc.PlantUML.Filter.OutputBlock ( src/Text/Pandoc/PlantUML/Filter/OutputBlock.hs, dist/build/Text/Pandoc/PlantUML/Filter/OutputBlock.o )
#
#src/Text/Pandoc/PlantUML/Filter/OutputBlock.hs:22:34: error:
#    * Couldn't match expected type `Inline'
#                  with actual type `Target -> Inline'
#    * Probable cause: `Image' is applied to too few arguments
#      In the expression:
#        Image (altTagInline attr) ((show imageFileName), "fig:")
#      In an equation for `imageTag':
#          imageTag imageFileName attr
#            = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |
#22 | imageTag imageFileName attr    = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#src/Text/Pandoc/PlantUML/Filter/OutputBlock.hs:22:41: error:
#    * Couldn't match type `[Inline]'
#                     with `(String, [String], [(String, String)])'
#      Expected type: Attr
#        Actual type: [Inline]
#    * In the first argument of `Image', namely `(altTagInline attr)'
#      In the expression:
#        Image (altTagInline attr) ((show imageFileName), "fig:")
#      In an equation for `imageTag':
#          imageTag imageFileName attr
#            = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |
#22 | imageTag imageFileName attr    = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |                                         ^^^^^^^^^^^^^^^^^
#src/Text/Pandoc/PlantUML/Filter/OutputBlock.hs:22:60: error:
#    * Couldn't match expected type `[Inline]'
#                  with actual type `(String, [Char])'
#    * In the second argument of `Image', namely
#        `((show imageFileName), "fig:")'
#      In the expression:
#        Image (altTagInline attr) ((show imageFileName), "fig:")
#      In an equation for `imageTag':
#          imageTag imageFileName attr
#            = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |
#22 | imageTag imageFileName attr    = Image (altTagInline attr) ((show imageFileName), "fig:")
#   |                                                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# pandoc-table failed :
#cabal: The following packages are likely to be broken by the reinstalls:
#texmath-0.10.1.1
#pandoc-2.1.3
#pandoc-include-code-1.3.0.0

# uninstall and clean
cd /root/.cabal
find ./logs/ -name "*.log" -exec rm {} \;
rm -fr packages/*
apt-get clean -y
rm -rf /var/lib/apt/lists/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/doc-gen/*
rm -fr /usr/share/man/*

exit 0

