#git clone https://github.com/abramhindle/flann.git

echo 'FLANN Autobuild script'
python ~/code/hotspotter/setup_localize.py build_flann
python ~/code/hotspotter/setup_localize.py localize_flann
