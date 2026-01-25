# Makefile for Aspire - Flutter + Firebase

# ============================================================================
# CONFIGURATION
# ============================================================================

FIREBASE_PROJECT_ID := aspire-bc5d7

# ============================================================================
# PHONY TARGETS
# ============================================================================

.PHONY: help assets watch reset \
	build-appbundle build-apk extract-symbols \
	deploy-all deploy-firestore deploy-rules deploy-indexes \
	signing-report clean analyze test

# ============================================================================
# HELP
# ============================================================================

.DEFAULT_GOAL := help

help:
	@echo "Aspire Makefile"
	@echo ""
	@echo "Flutter:"
	@echo "  make assets           - Run build_runner to generate code"
	@echo "  make watch            - Run build_runner in watch mode"
	@echo "  make reset            - Clean, get dependencies, run build_runner"
	@echo "  make clean            - Run flutter clean"
	@echo "  make analyze          - Run flutter analyze"
	@echo "  make test             - Run flutter test"
	@echo ""
	@echo "Build:"
	@echo "  make build-appbundle  - Build Android app bundle (.aab)"
	@echo "  make build-apk        - Build Android APK"
	@echo "  make extract-symbols  - Extract Android symbols (run after build-appbundle)"
	@echo ""
	@echo "Firebase Deploy:"
	@echo "  make deploy-all       - Deploy everything to Firebase"
	@echo "  make deploy-firestore - Deploy Firestore rules + indexes"
	@echo "  make deploy-rules     - Deploy Firestore rules only"
	@echo "  make deploy-indexes   - Deploy Firestore indexes only"
	@echo ""
	@echo "Utilities:"
	@echo "  make signing-report   - Get Android SHA-1 signing report"

# ============================================================================
# FLUTTER COMMANDS
# ============================================================================

assets:
	@echo "Running build_runner..."
	dart run build_runner build -d
	@echo "Done."

watch:
	@echo "Starting build_runner in watch mode..."
	dart run build_runner watch -d

reset:
	@echo "Cleaning..."
	flutter clean
	@echo "Getting dependencies..."
	flutter pub get
	@echo "Running build_runner..."
	dart run build_runner build -d
	@echo "Reset complete."

clean:
	flutter clean

analyze:
	flutter analyze

test:
	flutter test

# ============================================================================
# BUILD COMMANDS
# ============================================================================

build-appbundle:
	@echo "Building Android app bundle..."
	flutter build appbundle
	@echo "App bundle created at build/app/outputs/bundle/release/"
	@echo "Run 'make extract-symbols' to extract the symbols."

build-apk:
	@echo "Building Android APK..."
	flutter build apk
	@echo "APK created at build/app/outputs/flutter-apk/"

extract-symbols:
	@echo "Extracting symbols from Android build..."
	@TIMESTAMP=$$(date +%Y%m%d-%H%M%S); \
	cd build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/ && \
	zip -r symbols.zip . && \
	cp symbols.zip ~/Downloads/bundle-symbols-$$TIMESTAMP.zip && \
	echo "Symbols extracted and saved at $${HOME}/Downloads/bundle-symbols-$$TIMESTAMP.zip"

# ============================================================================
# FIREBASE DEPLOY COMMANDS
# ============================================================================

deploy-all:
	@echo "Deploying everything to Firebase..."
	firebase deploy --project $(FIREBASE_PROJECT_ID)
	@echo "Deployment complete."

deploy-firestore:
	@echo "Deploying Firestore rules and indexes..."
	firebase deploy --only firestore --project $(FIREBASE_PROJECT_ID)
	@echo "Firestore deployed."

deploy-rules:
	@echo "Deploying Firestore rules..."
	firebase deploy --only firestore:rules --project $(FIREBASE_PROJECT_ID)
	@echo "Rules deployed."

deploy-indexes:
	@echo "Deploying Firestore indexes..."
	firebase deploy --only firestore:indexes --project $(FIREBASE_PROJECT_ID)
	@echo "Indexes deployed."

# ============================================================================
# UTILITY COMMANDS
# ============================================================================

signing-report:
	@echo "Getting Android signing report..."
	cd android && ./gradlew signingReport
