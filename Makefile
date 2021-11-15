.DEFAULT_GOAL := help
.PHONY: all
#RFC=$(notdir $(wildcard mibs/*))
RFC=$(wildcard mibs/*)

# fetch:  ## Download all mibs from the source
# 	@# Wget recursive
# 	wget --recursive --reject-regex 'index.html*' \
# 	  --no-parent --no-host-directories http://mibs.snmplabs.com/asn1/
# 	rm -rf asn1/index.html*

output/asn1/$(notdir $(RFC)): $(RFC)
	@# Compile mibs
#Compile with notexts	
	poetry run mibdump.py \
	--no-python-compile \
	--mib-source=file://$$(pwd)/mibs/ \
	--destination-directory=./output/notexts \
	$(notdir $(RFC))
#Compile with notext	
	poetry run mibdump.py \
	--no-python-compile \
	--mib-source=file://$$(pwd)/mibs/ \
	--destination-directory=./output/texts \
	--generate-mib-texts --keep-texts-layout \
	$(notdir $(RFC))
	
	for u in $(RFC); do echo $$u; cp -f $$u output/asn1/; done

#compilerfc: mibs/$(RFC) ## Compile all MIBs into .py files
compilerfc: output/asn1/$(notdir $(RFC)) #mibs/$(RFC)

index: compilerfc ##generate index
	@# Generate index
	grep -Eo 'ModuleIdentity\(\(((?:\d(?:, )?)*)\)\)' output/notexts/* \
	| sed 's|output/notexts/||' \
	| sed 's|, |.|g' \
	| sed 's|.py:ModuleIdentity((|,|' \
	| sed 's|))||' \
	| sponge output/index.csv

compile-changed:  ## Compile With Texts all MIBs into .py files
	@for f in $$(git diff --name-only --diff-filter=AM HEAD mibs/asn1/); do \
		echo "## Compiling $$f"; \
		poetry run mibdump.py \
			--no-python-compile \
			--mib-source=file://$$(pwd)/mibs/asn1 \
			--destination-directory=./pysnmp \
			$$f; \
	done

compile-with-texts:  ## Compile With Texts all MIBs into .py files
	@for f in $$(ls mibs/asn1); do \
	  echo "## Compiling $$f with texts"; \
	  poetry run mibdump.py \
	    --generate-mib-texts \
	    --no-python-compile \
	    --mib-source=file://$$(pwd)/mibs/asn1 \
	    --destination-directory=./pysnmp-with-texts \
	    $$f; \
	done

compile-with-texts-changed:  ## Compile With Texts all MIBs into .py files
	@for f in $$(git diff --name-only --diff-filter=AM HEAD mibs/asn1/); do \
	  echo "## Compiling $$f with texts"; \
	  poetry run mibdump.py \
	    --generate-mib-texts \
	    --no-python-compile \
	    --mib-source=file://$$(pwd)/mibs/asn1 \
	    --destination-directory=./pysnmp-with-texts \
	    $$f; \
	done

compile-json:  ## Compile With Texts all MIBs into .py files
	@for f in $$(ls mibs/asn1); do \
	  echo "## Compiling $$f with texts"; \
	  poetry run mibdump.py \
	    --generate-mib-texts \
	    --no-python-compile \
	    --mib-source=file://$$(pwd)/mibs/asn1 \
	    --destination-format=json \
	    --destination-directory=./mibs/json \
	    $$f; \
	done

compile-json-changed:  ## Compile With Texts all MIBs into .py files
	@for f in $$(git diff --name-only --diff-filter=AM HEAD mibs/asn1/); do \
	  echo "## Compiling $$f with texts"; \
	  poetry run mibdump.py \
	    --generate-mib-texts \
	    --no-python-compile \
	    --mib-source=file://$$(pwd)/mibs/asn1 \
	    --destination-format=json \
	    --destination-directory=./mibs/json \
	    $$f; \
	done

help:  ## Print list of Makefile targets
	@# Taken from https://github.com/spf13/hugo/blob/master/Makefile
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  cut -d ":" -f1- | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
