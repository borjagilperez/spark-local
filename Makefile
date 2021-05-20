# $ make
# $ make all
all: info

GIT = git
SPARK = spark
.PHONY: info $(GIT) $(SPARK)

# $ make info
info:
	@echo "GIT: $(GIT)"
	@echo "SPARK: $(SPARK)"

# $ make git
git:
	@bash ./scripts/git.sh
	
# $ make spark
spark:
	@bash ./scripts/spark/spark.sh
