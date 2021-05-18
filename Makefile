# $ make
# $ make all
all: info

GIT = git
ESSENTIAL = essential
SPARK = spark
.PHONY: info $(GIT) $(ESSENTIAL) $(SPARK)

# $ make
info:
	@echo "GIT: $(GIT)"
	@echo "ESSENTIAL: $(ESSENTIAL)"
	@echo "SPARK: $(SPARK)"

# $ make git
git:
	@bash ./scripts/git/git.sh

# $ make essential
essential:
	@bash ./scripts/essential/essential.sh
	
# $ make spark
spark:
	@bash ./scripts/spark/spark.sh
