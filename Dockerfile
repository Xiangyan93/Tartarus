FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get upgrade

SHELL ["/bin/bash", "--login", "-c"]

RUN conda create --name tartarus python=3.8
RUN conda init bash
RUN echo "conda activate tartarus" >> ~/.bashrc

RUN conda install -c pytorch pytorch -y 
RUN conda install -c conda-forge rdkit -y
RUN conda install -c conda-forge openbabel=3.1.1 -y
RUN conda install -c conda-forge xtb=6.3.3 -y
RUN conda install -c conda-forge xtb-python=20.2 -y
RUN conda install -c conda-forge crest=2.12 -y

RUN pip install --upgrade pip
RUN pip install numpy
RUN pip install pyscf morfeus-ml

# additional packages for polanyi
RUN pip install h5py scikit-learn geometric pyberny loguru wurlitzer sqlalchemy
RUN pip install -i https://test.pypi.org/simple/ geodesic-interpolate
RUN pip install git+https://github.com/kjelljorner/polanyi

RUN mkdir /data
WORKDIR /benchmark

RUN echo "export XTBHOME=$CONDA_PREFIX" > $CONDA_PREFIX/etc/conda/activate.d/env.sh
RUN echo "source $CONDA_PREFIX/share/xtb/config_env.bash" >> $CONDA_PREFIX/etc/conda/activate.d/env.sh

COPY . .

SHELL ["conda", "run", "-n", "tartarus", "/bin/bash", "-c"]
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "tartarus", "python", "benchmark.py"]