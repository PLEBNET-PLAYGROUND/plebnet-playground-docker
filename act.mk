act-plebnet-playground:docker-start## 	run act -vbr -W .github/workflows/plebnet-playground.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr --container-architecture linux/amd64 -W .github/workflows/plebnet-playground.yml && popd
act-nostr-rs-relay:docker-start## 	run act -vbr -W .github/workflows/nostr-rs-relay.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr  --container-architecture linux/amd64 -W .github/workflows/nostr-rs-relay.yml && popd
act-codeql-analysis:docker-start## 	run act -vbr -W .github/workflow/codeql-analysis.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr --container-architecture linux/amd64 -W .github/workflows/codeql-analysis.yml && popd
act-codespell:docker-start## 	run act -vbr -W .github/workflow/codespell.yml
	@pushd $(PWD) && export $(cat ~/GH_TOKEN.txt) && act -vr --container-architecture linux/amd64 -W .github/workflows/codespell.yml && popd
