date=`date "+%Y%m%d-%H%M%S"`
cd ~
if [ -d ~/bin ]; then
  mv ~/bin ~/bin.$date
fi
git clone git://github.com/mikeadmire/home_bin.git ~/bin
cd ~/bin
/Users/mike/.rbenv/shims/bundle install
