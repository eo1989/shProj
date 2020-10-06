#!/usr/bin/zsh

# Just some notes for using TF w/ Bazel (think TF-Quant-Finance folder!)

# on linux
apt-get -qq update
apg-get install --no-install-recommends \
    xutils-dev zlib1g-dev libjemalloc-dev

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 25
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 25 # or gcc/++-7

echo "/usr/local/bin/cuda/extras/CUPTI/lib64" > /etc/ld.so.confi.d/cupti.conf

ldconfig
#############

conda install profobuf

cd /usr/local
tar zxf TensorRT-4.0.1.6.Ubuntu-16.04.4.x86_64-gnu.cuda-9.2.cudnn7.1.tar.gz
ln -s TensorRT* tensorrt
echo '/usr/local/tensorrt/lib' > /etc/ld.so.conf.d/tensorrt.conf
ldconfig
cd tensorrt
    cp python/tensorrt-4.0.1.6-cp35-cp35m-linux_x86_64.whl \
    python/tensorrt-4.0.1.6-cp37-cp37m-linux_x86_64.whl
pip install python/tensorrt-4.0.1.6-cp37-cp37m-linux_x86_64.whl \
  uff/uff*.whl graphsurgeon/graphsurgeon*.whl
#############

conda install \
  absl-py astor gast protobuf tensorboard termcolor \
  keras-applications keras-preprocessing
#############

mkdir -p /usr/local/nccl_redir
cd /usr/local/nccl_redir
for i in `ls /usr/local/cuda`; 
    do ln -s /usr/local/cuda/$i ./;
done
ln -s lib64 lib
#############

export BAZEL_VERSION=0.19.2
export BAZEL_FILE=bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
wget --progress=dot:giga \
  https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/$BAZEL_FILE
chmod +x $BAZEL_FILE
./$BAZEL_FILE
#############

git clone https://github.com/tensorflow/tensorflow
cd tensorflow
git checkout v1.13.2
#############
### Continue via https://nextjournal.com/nextjournal/tensorflow-1.13?change-id=CbTaKSjvUGbsw4L8Dg3KHF&node-id=e2fcaa50-5709-46e8-98d1-dd8ae49514a2#install-tensorflow-and-frontends-to-environment
###
