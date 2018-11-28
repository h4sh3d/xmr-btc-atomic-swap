TEX = pdflatex -shell-escape -interaction=nonstopmode -file-line-error
BIB = biber
NAME = xmr-btc
GLO = makeglossaries
TEXFILE = ${NAME}.tex
PDFFILE = ${NAME}.pdf
BCFFILE = ${NAME}.bcf

.PHONY: all clean clean_all

all : ${PDFFILE}

${PDFFILE} : ${TEXFILE}
	${TEX} ${NAME}
	${BIB} ${NAME}
	${TEX} ${NAME}
	${TEX} ${NAME}

clean :
	@rm *.bbl || true
	@rm *.log || true
	@rm *.out || true
	@rm *.blg || true
	@rm *.toc || true
	@rm *.aux || true
	@rm *.bak || true
	@rm *.pyg || true
	@rm *.backup || true
	@rm *.lof || true
	@rm *.synctex.gz || true
	@rm *.run.xml || true
	@rm *.bcf || true
	@rm *.glg || true
	@rm *.glo || true
	@rm *.gls || true
	@rm *.lot || true
	@rm *.xdy || true
	@rm -rf _minted* || true
	@rm *.mtc* || true
	@rm *.lol || true
	@rm *.maf || true
	@rm *.fdb_latexmk || true
	@rm *.fls || true

clean_all : clean
	@rm ${PDFFILE} || true

clean_atom:
	@rm ${PDFFILE} || true
