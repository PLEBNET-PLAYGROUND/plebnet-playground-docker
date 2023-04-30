act-plebnet-playground:## 	run act -vbr -W .github/workflows/plebnet-playground.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr -W .github/workflows/plebnet-playground.yml && popd
act-nostr-rs-relay:## 	run act -vbr -W .github/workflows/nostr-rs-relay.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr -W .github/workflows/nostr-rs-relay.yml && popd
act-codeql-analysis:## 	run act -vbr -W .github/workflow/codeql-analysis.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr -W .github/workflows/codeql-analysis.yml && popd
act-codespell:## 	run act -vbr -W .github/workflow/codespell.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr -W .github/workflows/codespell.yml && popd
