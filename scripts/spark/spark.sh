#!/bin/bash

PS3="Please select your choice: "
options=(
    "Install" \
    "Recreate pyspark_env" \
    "Version" \
    "Spark shell" \
    "SparkPi example" \
    "PySpark shell" \
    "PySpark, PandasUDF example" \
    "Spyder, open" \
    "Jupyter notebook, start" \
    "Uninstall" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Install")
            tmp_dir='/tmp/spark/local'
            rm -rf $tmp_dir && mkdir -p $tmp_dir
            wget https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz -P $tmp_dir
            tar -zxf $tmp_dir/spark-3.1.2-bin-hadoop3.2.tgz -C $HOME
            mv $HOME/spark-* $HOME/spark
            chmod 777 $HOME/spark && chmod 777 $HOME/spark/python && chmod 777 $HOME/spark/python/pyspark
            wget https://repo1.maven.org/maven2/org/postgresql/postgresql/9.4.1207/postgresql-9.4.1207.jar -P $HOME/spark/jars
            wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.375/aws-java-sdk-bundle-1.11.375.jar -P $HOME/spark/jars
            wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar -P $HOME/spark/jars

            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            conda env create -f ./scripts/spark/environment.yml
            conda activate pyspark_env && conda info --envs
            python3 -m ipykernel install --user --name=pyspark_env
            jupyter kernelspec list

            break
            ;;

        "Recreate pyspark_env")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            jupyter kernelspec remove -f pyspark_env
            conda remove -y -n pyspark_env --all
            conda env create -f ./scripts/spark/environment.yml
            conda clean -y --all
            python3 -m ipykernel install --user --name=pyspark_env
            jupyter kernelspec list

            break
            ;;

        "Version")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark_env && conda info --envs
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3

            spark-submit --version
            echo ''
            spark-submit ./examples/src/main/python/python_version.py

            break
            ;;

        "Spark shell")
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            spark-shell

            break
            ;;

        "SparkPi example")
            export VAULT_ADDR='http://127.0.0.1:8200'
            vault login

            read -p 'Owner: ' owner
            branch=$(git branch | grep '*' | awk -F' ' 'NR==1{print $2}')

            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            spark-submit \
                --name spark-pi \
                --master local[*] \
                --packages co.datamechanics:delight_2.12:latest-SNAPSHOT \
                --repositories https://oss.sonatype.org/content/repositories/snapshots \
                --conf spark.delight.accessToken.secret=$(vault kv get -format=json kv/$owner/$branch/spark/datamechanics | jq -r .data.data.delight_access_token) \
                --conf spark.extraListeners=co.datamechanics.delight.DelightListener \
                --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_*.jar

            break
            ;;

        "PySpark shell")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark_env && conda info --envs
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            pyspark

            break
            ;;

        "PySpark, PandasUDF example")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark_env && conda info --envs
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            
            tmp_dir='/tmp/spark/local/pandasudf' && mkdir -p $tmp_dir
            launcher='./examples/src/main/python/pandasudf_script.py'
            spark-submit \
                --name pandasudf-example \
                --master local[*] \
                $launcher \
                2>&1 | tee $tmp_dir/spark-submit-client.log
                
            break
            ;;

        "Spyder, open")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark_env && conda info --envs
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            spyder 1>/dev/null 2>&1 &

            break
            ;;

        "Jupyter notebook, start")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate pyspark_env && conda info --envs
            export SPARK_HOME=$HOME/spark && export PATH=$SPARK_HOME/bin:$PATH
            export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH
            export PYSPARK_PYTHON=$(which python3) && which python3
            export PYSPARK_DRIVER_PYTHON=jupyter
            export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
            cd $HOME
            pyspark

            break
            ;;

        "Uninstall")
            rm -rf $HOME/spark
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            jupyter kernelspec remove -f pyspark_env
            conda remove -y -n pyspark_env --all
            conda clean -y --all

            break
            ;;
            
        "Quit")
            break
            ;;
        *)
            echo "Invalid option"

            break
            ;;
    esac
done
