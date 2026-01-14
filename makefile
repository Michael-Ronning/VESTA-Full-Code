
BASE_HREF = '/Vesta_App/'
GITHUB_REPO= https://github.com/neuropsychologyinnovationlab-sudo/Vesta_App.git
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')

deploy-web:
	@echo "Cleaning previous build...🗑️🚮"
	flutter clean

	@echo "Getting dependencies...👍🏻"
	flutter pub get

	@echo "Building web app...👷🏻💻"
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Deploying to GitHub Pages...📑"
	cd build/web && \
	git init && \
	git add . && \
	git commit -m "Deploying version $(BUILD_VERSION)" && \
	git branch -M main && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u --force origin main

	@echo "Deployment complete! ✌🏻 ✅"
	cd ../..

.PHONY: deploy-web