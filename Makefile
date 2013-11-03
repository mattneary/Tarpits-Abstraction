LATEX = latex -quiet
TEXODE = texode
FLAGS = -b book
DVIOUT = dvi
TEXOUT = ./build/latex
define render
	$(TEXODE) $(FLAGS) chapters/$(1).md $(TEXOUT)	
endef	

all: computation bootstrap interpret sfuncs simulate compile clean

bootstrap: chapters/Bootstrap.md
	$(call render,Bootstrap)
	
computation: chapters/Computation.md
	$(call render,Computation)	
	
interpret: chapters/Interpret.md
	$(call render,Interpret)

simulate: chapters/Simulate.md
	$(call render,Simulate)
	
sfuncs: chapters/SFuncs.md
	$(call render,SFuncs)	
	
compile: chapters/*.md
	$(LATEX) $(TEXOUT)/book.tex
	mv book.dvi build/dvi/
	dvipdf build/dvi/book.dvi build/pdf/book.pdf	

clean:
	- $(RM) *.log
