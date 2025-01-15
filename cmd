# To activate this environment, use
#
#     $ conda activate sync_3_8
#
# To deactivate an active environment, use
#
#     $ conda deactivate
#

python 3.8 ， cuda: 11.8
pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu118


# input image should be 224 * 224
python demo_syncnet.py --videofile data/example.avi --tmp_dir ./tmp/example


python demo_syncnet.py --videofile ../data/mp4_face_dir/altman/0_altman_1977_2268.mp4 --tmp_dir ./tmp/alt19

python demo_syncnet.py --videofile ../data/mp4_224_dir/altman/0_altman_1977_2268.mp4 --tmp_dir ./tmp/alt19xx


