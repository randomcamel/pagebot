default:
	@echo "Type 'make deploy' to deploy."

deploy:
	rsync --delete -aCPv . shiny:pagebot
