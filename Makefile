SHELL := /bin/bash
PHP := $(shell which php) $(PHP_EXTRA_ARGS)
COMPOSER := $(PHP) $(shell which composer)
JQ := $(shell which jq)
JSON_FILES := $(shell find . -name '*.json' -not -path './vendor/*')

.PHONY: all
all: clean it

.PHONY: clean
clean:
	[[ ! -f composer.lock ]] || rm composer.lock
	[[ ! -d vendor ]] || rm -rf vendor
	[[ ! -d .build ]] || rm -rf .build

.PHONY: it
it: cs-fix-composer-normalize csfix cs releasecheck

releasecheck: frosh-plugin-upload
	[[ -d .build/store-build ]] || mkdir .build/store-build
	git archive --format=tar HEAD | (cd .build/store-build && tar xf -)
	[[ ! -d .build/store-build/.git ]] || rm -rf .build/store-build/.git
	cp -a .git/ .build/store-build/.git/
	(cd .build/store-build && ../frosh-plugin-upload plugin:zip:dir .)
	.build/frosh-plugin-upload plugin:validate $(shell pwd)/.build/store-build/*.zip

.PHONY: cs
cs: cs-fixer-dry-run cs-phpstan cs-psalm cs-soft-require cs-composer-unused cs-composer-normalize cs-json cs-admin-js cs-admin-style

.PHONY: cs-fixer-dry-run
cs-fixer-dry-run: vendor .build test-results
	$(PHP) vendor/bin/php-cs-fixer fix --dry-run --config=dev-ops/php_cs.php --diff --verbose --allow-risky=yes --format junit > test-results/php-cs-fixer.xml

.PHONY: cs-phpstan
cs-phpstan: vendor .build test-results
	$(PHP) vendor/bin/phpstan analyse -c dev-ops/phpstan.neon --error-format=junit --no-progress > test-results/php-stan.xml

.PHONY: cs-psalm
cs-psalm: vendor .build test-results
	$(PHP) vendor/bin/psalm -c $(shell pwd)/dev-ops/psalm.xml --no-progress --diff --show-info=false

.PHONY: cs-composer-unused
cs-composer-unused: vendor
	$(COMPOSER) unused --no-progress

.PHONY: cs-soft-require
cs-soft-require: vendor .build
	$(PHP) vendor/bin/composer-require-checker check --config-file=dev-ops/composer-soft-requirements.json composer.json

.PHONY: cs-composer-normalize
cs-composer-normalize: vendor
	$(COMPOSER) normalize --diff --dry-run --no-check-lock --no-update-lock composer.json

.PHONY: cs-json
cs-json: $(JSON_FILES)

.PHONY: cs-admin-js
cs-admin-js: admin-npm
	npm run --prefix src/Resources/app/administration lint:js:ci

.PHONY: cs-admin-style
cs-admin-style: admin-npm
	npm run --prefix src/Resources/app/administration lint:scss:ci

.PHONY: $(JSON_FILES)
$(JSON_FILES):
	$(JQ) . "$@"

.PHONY: cs-fix-composer-normalize
cs-fix-composer-normalize: vendor
	$(COMPOSER) normalize --diff composer.json

.PHONY: csfix
csfix: vendor .build cs-admin-js-fix cs-admin-style-fix
	$(PHP) vendor/bin/php-cs-fixer fix --config=dev-ops/php_cs.php --diff --verbose

.PHONY: cs-admin-js-fix
cs-admin-js-fix: admin-npm
	npm run --prefix src/Resources/app/administration lint:js:fix

.PHONY: cs-admin-style-fix
cs-admin-style-fix: admin-npm
	npm run --prefix src/Resources/app/administration lint:scss:fix

.PHONY: composer-update
composer-update:
	$(COMPOSER) update

.PHONY: admin-npm
admin-npm:
	npm ci --prefix src/Resources/app/administration

.PHONY: frosh-plugin-upload
frosh-plugin-upload: .build
	[[ -f .build/frosh-plugin-upload ]] || php -r 'copy("https://github.com/FriendsOfShopware/FroshPluginUploader/releases/download/0.3.2/frosh-plugin-upload.phar", ".build/frosh-plugin-upload");'
	[[ -x .build/frosh-plugin-upload ]] || chmod +x .build/frosh-plugin-upload

vendor: composer-update

test-results:
	mkdir test-results
	echo '*' > test-results/.gitignore

.PHONY: .build
.build:
	[[ -d .build ]] || mkdir .build

composer.lock: vendor
