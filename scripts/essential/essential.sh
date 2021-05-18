#!/bin/bash

PS3="Please select your choice: "
options=(
    "OpenJDK 11, install" \
    "Essential, install" \
    "Essential GUI, install" \
    "Upgrade and clean all" \
    "Miniconda 3, install" \
    "Recreate base environment" \
    "Update conda base" \
    "Clean" \
    "Miniconda 3, uninstall" \
    "Spyder, open" \
    "Jupyter notebook, start" \
    "Jupyter notebook, choose browser" \
    "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "OpenJDK 11, install")
            sudo apt-get install -y openjdk-11-jdk openjdk-11-jre
            java -version
            echo >> $HOME/.bashrc
            echo '# Java OpenJDK 11' >> $HOME/.bashrc
            echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HOME/.bashrc
            echo 'export PATH=$JAVA_HOME/jre/bin:$PATH' >> $HOME/.bashrc
            sudo update-alternatives --config java
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Essential, install")
            sudo apt-get install -y build-essential curl git git-flow jq nano nmon snapd unzip wget

            # Scala
            wget https://www.scala-lang.org/files/archive/scala-2.12.10.deb -P /tmp
            sudo dpkg -i /tmp/scala-2.12.10.deb && sudo apt-get install -y --fix-broken
            scala -version
            # sbt
            echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
            curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
            sudo apt-get update && sudo apt-get install -y sbt

            break
            ;;

        "Essential GUI, install")
            sudo apt-get install -y gitg terminator
            sudo snap install code --classic
            sudo snap install intellij-idea-community --classic
            sudo snap install pycharm-community --classic
            sudo update-alternatives --config x-terminal-emulator

            break
            ;;

        "Upgrade and clean all")
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt-get autoremove -y && sudo apt-get autoclean

            break
            ;;

        "Miniconda 3, install")
            rm -f /tmp/Miniconda3-latest-Linux-x86_64.sh
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -P /tmp
            bash /tmp/Miniconda*.sh -b -p $HOME/miniconda
            
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda init bash
            conda config --add channels conda-forge
            conda update -y --all
            conda env update -f ./scripts/essential/environment.yml
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Recreate base environment")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base && conda info --envs
            #conda env update --prune -f ./scripts/essential/environment.yml
            pip uninstall -y $(conda list | grep 'pypi' | awk -F' ' '{print $1}' | sed -E ':a;N;$!ba;s/\n/ /g')
            echo 'Installing revision 1, please wait.'
            conda install -y --revision 1
            conda env update -f ./scripts/essential/environment.yml
            conda clean -y --all
            echo -e "\nYou can check revisions running \$ conda list --revisions"

            break
            ;;

        "Update conda base")
            conda update -y -n base conda

            break
            ;;

        "Clean")
            conda clean -y --all

            break
            ;;
            
        "Miniconda 3, uninstall")
            eval "$($HOME/miniconda/bin/conda shell.bash hook)"
            conda activate base
            conda clean -y --all
            conda init --reverse bash
            rm -rf $HOME/miniconda $HOME/.*conda*
            echo -e '===========\nRun the following command to restart environment variables: $ source $HOME/.bashrc\n==========='

            break
            ;;

        "Spyder, open")
            conda info --envs
            spyder 1> /dev/null 2>&1 &

            break
            ;;

        "Jupyter notebook, start")
            conda info --envs
            cd $HOME
            jupyter notebook

            break
            ;;

        "Jupyter notebook, choose browser")
            conda info --envs
            jupyter notebook --generate-config
            echo 'change c.NotebookApp.browser'
            echo 'Where is Firefox?'
            whereis firefox

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
