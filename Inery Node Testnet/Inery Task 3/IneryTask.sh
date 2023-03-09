# Set Vars
if [ ! $IneryAccname ]; then
        read -p "ENTER YOUR INERY ACCOUNT NAME : " IneryAccname
        echo 'export IneryAccname='$IneryAccname >> $HOME/.bash_profile
fi

echo ""
echo -e "YOUR INERY ACCOUNT NAME : \e[1m\e[35m$IneryAccname\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[35m$CHAIN\e[0m"
echo -e "NODE PORT      : \e[1m\e[35m$PORT\e[0m"
echo ""
sleep 3

# Install build-dep

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y make bzip2 automake libbz2-dev libssl-dev doxygen graphviz libgmp3-dev \
autotools-dev libicu-dev python2.7 python2.7-dev python3 python3-dev \
autoconf libtool curl zlib1g-dev sudo ruby libusb-1.0-0-dev \
libcurl4-gnutls-dev pkg-config patch llvm-7-dev clang-7 vim-common jq libncurses5 git

## Clone dari official github
cd ~
git clone --recursive https://github.com/SaujanaOK/inery.cdt.git

# Set PATH env
echo 'export PATH="$PATH:$HOME/inery.cdt/bin:$HOME/inery-node/inery/bin"' >> $HOME/.bash_profile
source $HOME/.bash_profile

# Buat directrory
mkdir -p $HOME/inrcrud

# Write code
sudo tee $HOME/inrcrud/inrcrud.cpp >/dev/null <<EOF
#include <inery/inery.hpp>
#include <inery/print.hpp>
#include <string>

using namespace inery;

using std::string;

class [[inery::contract]] inrcrud : public inery::contract {
  public:
    using inery::contract::contract;


        [[inery::action]] void create( uint64_t id, name user, string data ) {
            records recordstable( _self, id );
            auto existing = recordstable.find( id );
            check( existing == recordstable.end(), "record with that ID already exists" );
            check( data.size() <= 256, "data has more than 256 bytes" );

            recordstable.emplace( _self, [&]( auto& s ) {
               s.id         = id;
               s.owner      = user;
               s.data       = data;
            });

            print( "Hello, ", name{user} );
            print( "Created with data: ", data );
        }

         [[inery::action]] void read( uint64_t id ) {
            records recordstable( _self, id );
            auto existing = recordstable.find( id );
            check( existing != recordstable.end(), "record with that ID does not exist" );
            const auto& st = *existing;
            print("Data: ", st.data);
        }

        [[inery::action]] void update( uint64_t id, string data ) {
            records recordstable( _self, id );
            auto st = recordstable.find( id );
            check( st != recordstable.end(), "record with that ID does not exist" );


            recordstable.modify( st, get_self(), [&]( auto& s ) {
               s.data = data;
            });

            print("Data: ", data);
        }

            [[inery::action]] void destroy( uint64_t id ) {
            records recordstable( _self, id );
            auto existing = recordstable.find( id );
            check( existing != recordstable.end(), "record with that ID does not exist" );
            const auto& st = *existing;

            recordstable.erase( st );

            print("Record Destroyed: ", id);

        }

  private:
    struct [[inery::table]] record {
       uint64_t        id;
       name     owner;
       string          data;
       uint64_t primary_key()const { return id; }
    };

    typedef inery::multi_index<"records"_n, record> records;
 };
EOF

# Compile code
inery-cpp $HOME/inrcrud/inrcrud.cpp -o $HOME/inrcrud/inrcrud.wasm

# Deploy contract
cline wallet unlock -n $IneryAccname --password $(cat $HOME/$IneryAccname.txt)

# Set contract
cline set contract $IneryAccname $HOME/inrcrud

# Menu

PS3='Select an action: '
options=(
"Create Contract"
"Read Contract"
"Update Contract"
"Destroy Contract"

"Create Contract") # create
clear
cline push action $IneryAccname create '["1", "'"$IneryAccname"'", "My first Record"]' -p $IneryAccname -j
read
sleep 3
clear
continue;;

"Create Contract") # read
clear
cline push action $IneryAccname read '[1]' -p $IneryAccname -j
sleep 3
read
clear
break;;

"Create Contract") # update
clear
cline push action $IneryAccname update '["1",  "My first Record Modified"]' -p $IneryAccname -j
sleep 3
read
clear
break;;

"Create Contract") # destroy
clear
cline push action $IneryAccname destroy '[1]' -p $IneryAccname -j
sleep 3
read
clear
break;;

# End
