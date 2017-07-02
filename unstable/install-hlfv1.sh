ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.9.1
docker tag hyperledger/composer-playground:0.9.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �YY �=Mo�Hv==��7�� 	�T�n���[I�����hYm�[��n�z(�$ѦH��$�/rrH�=$���\����X�c.�a��S��`��H�ԇ-�v˽�z@���W�^}��W�^U��r�b6-Ӂ!K��u�lj����0!��F�������6�r�D�8��a�(�? �ѿZ�+� <pm��9W�M��=�6��4��2�LQ�ۚ�5�����ƿW�hr��cI�֔�(�ѵ��C��H/>Х�eڮ�e	@,�0+��o��A��٦ф��CJ泅|Y*%�Lz|�G �� ���ݤiPqQ�
�Y�tH����䪭)�`
e�A��<A �p��5qe�>O�bk&�7/+l�$�͆��t.B�sn���'��+�e״	V�a6a��#�FM	!��CF3ך�l�(e�aFbM[�6�(��P���e똋�m)k���>�䦥�0bk-��=��b(��/JCF-Drov{?F����Ia��]g���(�"�i�K��k!�y���HV�VD.����Vmxڂ��S�T.΃	���ì���l#I�6��mD]{1(Z6TeM�g���NT���\��S�R�*�0ȇա�f���2��1�2����7��3چ�����!��ǥ�{�~�5DH���Q��9<���>~��П��Q��1��= ��s2>��L��P�U�cxT�iܖi���g9�?������Ǹ�B��<�*RՌHUv�c�l��S��䏪�x(D��by��)%�7��<���_����ȑn�h�G��8H��a��c���y���F�?X���c�ߒ���;�q'4��'v���ey�ȿ�s\���'c�?����v�3����0
f�Q/tضuڠL��� ׬��<�� dC%�P3m�kCݴ��韎����^>���e���-H���0�!����k
4R"u�q^�	���z�����(-&�5&]6�.����o��Z�@�YE�z���!E�ߘ*N�	ɺՐýy�z,l�A�-����0���55�Us�t���jH����&,���n�P��v,��k A��Utjlq0&!�^r�CC�s͋bñ��ʋB-�Ǭ����pa	}�b17|pp��O�����
8A������(�Y���A��z��j-�Łې]p��:�m�4�B`�C3ꗛ�O並�����
����*�B�r@������MX�A~�h�}��4���	�-D�-#��th ���a#FKױ%ϣ@�$9S5���A�ܕ�K��=�Ӑ���dB5L���F��`��]��@�E��<Rg�K�}l,����d潴�1�a�L{l��ܓ�@���g�a���͸����o6}F��� ��z�i�]R)�:�ѹ1胘��.���Z��+��]eWli.I�yWM��u��<�P����ԡ�NCS�$��Д��?%|HeCگu2~�Ә���3�@3p����)Z<�DLx�j���ӷSxFD�% U�'/_^"Q�#zU�r4a��3��á#+�jp19�0f�ǝ��l?f��||���,�?7���˶�#�ś=C��.��OGJ]�_<��39����a5�b����vӶ\���m�Ш�4��R�Li��	U�̔���R�PY��M�O����Z]�_,?y@�X�,E9t�4�1Q�$�v�R9��=?��T�}�w hht_ %�i51��a�%0�`�wС�����D9����(�,^���[����Q%���;���@�;˃�D��:�F�0�z��2`�І��?{ÄV�>B���_�7o��������}���X^���!5\F�Y�6���{ITR�ⴸN&t�B�jE�u�:�q�-Bw�B�"���ƌ�
Z5�����=�n3̬�qL|������c�����p��GYfX��ǘ����^���7��Vhj]��eÚvz�8ʸϠ?�/F�[��җnOcv��8#������W8LX�E?�4�����8���h��ӷ��݂'����pQ>������%�
7��@�6���5��7D�M�P�0�W�!ؾ����e[n�\��G�ݑĶ)�t6�B|��A�<e!2�O7z;ƈ�,i0C��}���Hk0�Pt((�����g��������[_���j�w
��� d���#��1�˳j!?+'�K�E���� Bi�����n����[��<�C����1���=\ٓX]&�c��!�s.�3�©��^}���ޡس�H���0fz�0��]��q{������m��.:$��_��\���{��j�G��Y`z�/Ib*+����4&��3?l�gyvq��\��c�c�8�C�e���P�/��	���ͷ'�DG��/�������!�\{^r�bp�u�K�y�t�fd�Rd|�-���YٿD!��(�HM���ј&�.NC���U;�ws�"��q�����C����!�}l����F{�CW�<y���J㫿�F��nv�dͭhމ�(�?��m�#YIQ�Ӟ�ypn���^k��Bh���{�UG��^�����_�a�ϰ�=-�	��a�O��-��y�? �m�}3�/�7\�Qwx��2��p��]�W�k` ��[�pҬ�MH�ri7y��D�Oʉ�m)���y@�-�z���8�!�\9�a�H�p��ry�!�̗���$���T�$���N%��*R�B���fQIR�|&WYo��#mَ�-×�����l���L.}�-�J��))��!�I��	.le�$Ty��z�Eq��Ů̆�]��,%wJ���@#^�P�oo��`���P����ϒTY�v��f�tܲ���k�I���Z�:R���Ch�%�]�
�sɸ�ۦ�j�~>�hm\�}��,����M��Ǆ����b��|��?�7z?�+H�hYW�3��\B*��qz@v��z��ٻ� LuXe�

�+� O1����K|�x��xe��͒ŮO�~ר���?{+/�i�?���������i��6��M����C�E���?�P�o��A���+�G'��v��q	O'�2�\H=��Fd��&��zF/���F����� !x��ʻ��X��.��{�i���\
8Y������������;���l��x�pU�+OJ��7H�@�={2����3[JC��Ix]�O+���b����9��|���Ɋ �����.���л�ˣ��	Gp>�i��6��'�������|�A�\,�/�s����{��aZ/�k��,���z��V�kT.���� ȏR�1��ω|3�}��jq&G_x'�'�����;�p�OC��l���ϭ?�2��p�K*���S���D�X׈~�1��G�	��*�qo�\�n�U��^�!^���]�M`���������`�����ƣ��?�3��7��Dc���2���ܰ���4MCc���f����	�B����'���[/���(�?CѶI��ی/h���M�.~�Q,4P���e��w8�^{G;Z��2D�r�e��U!�*��*�kQ(�U^^a���1���5����1�j���֔�ReU�"Z?�w4�[��$^�
�]��)��x:�!!�39��J��F&)V$zhd3���q2)����$�z���-
��]�U�==���j�i��[�z��qr�/�)�8���Ρ�,�v�Ŵ�y��s.U�����H�Dv��m8��A[i��~E��&�$.q���p��t�=4���c�u�z.d����-V���l��az�U�g�v3׮V.q�3�p�7:�Y�\d�Ǚ����Ud����~Xv�9C�8_%�݄�_��J���H^�2R�J��Y��n��7���ΆH�6�[�ߋ����Qm�,�˵���Φ�:�J$ҬU=I�zPζ����=�SM���U7�qґ:���Ɩy�9?f�bq?��Ģ�*�E)�ʕ�'��iU�ӵN�uysk��:��������Ccs7���Ė��:�u�������ƞ���Xу|�<���;�n�9�e�b'UG���¡!7#	�o}��Mdq=����lV4�ɤ��;��Y�C⤎��t�ɬ(v�:��C�s�H;S�����9��,,z��5W]9oo�^�M;���\���'��4;ɺW�C�[B}1Uꈝ���W��-s��h�ӌ�j��j%��J�l�|R[I�k��rZ�&�I�Cc�T,XL��*���s�zv��v���ȧF�}�N�3�H�� b �RcD������qj�p�ۦQ�֌�������7��a��a�� �TFx ��?Л�m�t�Û�{
7��n;w���.�]�̧�'��LT��(�-��t�B)��&}�%��GT6��뒈��D�4]��V�o����i3�f:2֗��z��~�+	9�Vw�bǏ(۬o�V^5��Ǫ��+"W������n�$撢X���W�^Q�,��9��jF��f�b;�(>V�w�����);ҩZR�ۉ��J�m[�Te�͕ʆz�og3�"��-9b=���h���?�0������/��y������}}>���7�/�s�������$�ӿo���9��3��l�)��'�a���~80����3��ٔ4&���������� ��O�w��g���g������?�?��7?eW�«5��c�U�2��*��e!�pB�gclT��J��)LU`�U~EXYY�`��_�C�7��-�y�/�����_�b�/?}����f],��!�7�K�K��g�OD�ұ�^3��/�~B�8o׹l�������_��4Ǵ]��\���%�2q$���>Y��O�<�쓁|(�_R?";!��K�٧KT��Q܏�l�Er��'K�P��� W��B�@�����4/��~����w�������G�ۇ����<=�]���^���nˆ�������k &ȿ�F�������������X�)��/%�'��r�3�W��!M��=��=A����z�Jdl�~���,�v��ʉ(�An	~�R ����S����?_B!a,���f"�����#&Z��pa6�O`w��d�o#%���,W��*e>
�|Mj�k�����U���*�Vk�ڪ �b+P���9����F��: �z����uFj~�r�u쉅�G�����+�q�Ξx2��L�'
fqq:�dz`a��HQ42�DI%q%*�����BQ���Ns�!���bd1��d�,v�1`�7Aı� @r��䐒�JUR-��]*O�P]->.���o��{�/ 4��~��^�۬����8ف~xNޒ�R�6����[�׋��/�٪İR,q[a%��4lX�j0-}�\�V���j�(y}z�s!w�\�V)T�G���+X������G~<U�G�5�B7�H������h�+�"���?Wr'i�O���j���Q�8�Mw��>�Ǡ�����qǝ������:s��U��ṕ~��c�p/�{ST�G���U���م���s'�-������"Qr��h������
?鍑�n�\��H���?��5����e~A�υk���-Iz�\6��\��^�s�A��8] ���\���m�,݅Y��)���V�E�F*��k6yvp˩�v��%����~5�I�Om��󣤃\h���5\�e]����#�'{�:�,�Ov`��H^��0-�n�+I0�i�'&�h5;��4R����#�S�Ti>�z���,��q�UU��tl�>^u|;7�,����
������)�����.᧫u��P����w<���\X���>���.8�kv�O>\}���<�ۋ�nVx}��,�&]�'����5����M'���/�8�~�+�i��>��f�,�-%a�ʹ<x�m~ae��9N$�T춠$C=�K��7�����e/���3�(�O=���ՠ�����������0����
����G���J����W�?������>��G�����~O3�I�������̀�<x�͗_9�ǯ&��ג|ۅ�p�/��n�����X.�������L��fP��q�@(�g�!�;�je�M\O�ޭK�������������������_��7R?T�VR���~���i�,L������%���茶��i��/�9�ݷ��'��۩�����N��Kr��$5Xfh�����`�����A��3.���ǃtW3N�7W�����e@ ��lߎ@��0e礴̱u�[��\����I��N�Y_3F�����DCzs!��B6���r�Yk�NZ�NGoRaK�<��x���)*t���Q�)��	^i$�y�Ϣ��<*��$8I��M��LT��*�T���<�#��辪�M�����DN� O��r5h���f�����pߋ�g���8$$��V�Zh�L�öxm�df���,��9���JF� �Y�#Eʑ��I�r��yJ4C��`���	�RH&�9����R4��ܞ#+@=]�[G�*a���q+�i�HE�m{�ӝJ�d�<��(k���@�u+A�>u
�Fx��%Jʕ�b�H�W�	�.�6<u�Z��:P�����Evl晾�A��T��"��M��e����+V�'�J◫*������YI �� DQ��Ԟ�]�4y"Â��k7�xl��a�9��G*��FL��E';�j�3%�*�Rėl� i��$w�pI<f�P����=}L����}p�a,;L�"���<ꌳ�n�!8�����.ª�^�E�S=�.P��$�@j�PФH.��%�JQ�ϋ�(�R���*̘��� cU@�Z�Y�DM���y�3��,�����MB)�u�HN�4����\�I208ʇ�5�y��6[e.���\�M�!�H0�šd�����̏[�W(O�+��7zY$���D�v*,�3��@N	����Y�ɷ�2#��,R��$�sV�F�Y�X���s��&��D�6��y�Q�;P��_og6���'R�	j����6j6����*)z�a9�|��Ba)�2$�7�����txd�A����!A�Є+�J�-��	/�e6��u,(�)U��_��,\�-5j�U/V:S�Ҥs�������&�<�M+y��� 7��nZ�ܴ��ip��%<�M+x��� ׭߹d�Po /�I�������V�{��V���~���;���+�?s��ג��y|r|�1� �K1��N�����x�79���M�w�S�������8�ֽ��������������wi~�x��h��t,%:���ȧ���vb��c�o0�5�ݽ���tM���Ҥ @�r^ڕ�3�z���L��+���P��lM
�*�Qly�F�h>l+����5͙ ��R�ƌU"2�o�x�8E��p=m�Z�v��zp���`�l�C�M���+hN�4���Β.�4����Rhs��jc��g��dà;R:�B;T'Nѱ<��:͆k����d]�L(�V7��t����>(>cKzNa��KVM����+e��{�8.U��U���R�`ynԝ6ᨓ1�q�l�f��ˋ�V+B'�v$�;�lFd2{#�	2u�q�p�*-!�0_���kJ[o{������S�J]Xe�}p0@Jf��ihJ����Gy�Q9�95���1��U,Yjf\#�����j�؎���d��9�<1��0U��,�j�jZ��T����B�*�%bՀ�P�L���TIv
�M�"O�b��P��{o�ˬ;:i�����s�Y�����O?��Ot�ߧ��/�-R�N�� 8�H��������}����o>8s��WBL%q���Tq��8 �Z.�'e�E���	7w�{֊;ϐ�⦑s�Q#�Y�]6��
�İ�i�uT�V�QX{4~��V�x�K&�X>ob4R�����"u
�EEI�� �#gF�;�3�H����Xw7��5ւ��&�G��c�Hr��/tJe+S�M5�Sёo��Z�b}t.pݠ"�H7j��j2@A$�:6q<�Z�-]�E��>����$��Q�X/Ħ��s� %�'�"�16ĸ3'��-fآ#:x���E�C�`�"�u���-O}�td�z$:�� nd�K#� &��Y���,뵐F6S�]�B�6Zb���ZO1��H���c����ӣzP$�Ee��ǃBu Ѩ�M��[��<���N;c�ѥ�o]/1�,���K�ޚDQ9^�V�������� `�q������ !���@8`��n���P�b��t&�t,�S9� F���%]��Fc,�0����%pɘ�v>8<Vȫ͹���Mh�ݝ��5�X�6X��NhM%Aو�����ǁ����H��#K�l:���ZӁ��ʸ��F�S�jj�7�y�fb����A��
A�������m��rƏjC��a���$�ڥB���ؽ������s��9^�}�}�j���V}ƢU�������w�v%a1�k��֤v1D�!�@�H�mB�Ok�!���~đ����q8�ڈ
��#�.��)�`̲�!Ub,�F�FY�����p"ؕ�ǌT)�$�4`��VC�װ��oX��KPc�I�c]�y��Q�~�˸C��2|����:��tx��͓�j0�Zt��{�|^��j��\w4�Z��U%��E#kP���xm�t��z �[�Ks���4F규<�{���x�Q�-�m�<?j*�K�5���p��cԊ9X%@��j�ȱ��������o^W�0���F?H}����Z����둽�����?	9	�^�����/���hJV8����a�����W�{I��5'�2Z�7S� /�~�?<-�}�j����έ�[���7?��{�|r�2�/x�e���ϧ~�Y��'����;�w�U����;窉�x�������'<_�@%y�j���狮w2T�o�z�����1S��J%1߳�!��ŵ����:A�&Ƣ�8�����vxs5?�i��0��ԯ��w�U�%EZ�|0�1�'�p |n���S�Y/���=���w����߷A7��Ͳ�-�x��G!A������l�i�E!x?��Aw��o������n����_�j��{�i;���?�����۠�����,����6����Z�]���������?�n�v���A;��E'��5��C�����;�ٌ� {���;��ؑ��¾����(��_������<����O�B�>
w��s�G��Q��J}>t'�?xK�7���n�vl����S���/��w'�?������߻�;����c������|+����b�}?��X?�]/�'�;a���?X���A;���WW�# ;����b�w����{���3���ax�t���o���������//:����K��+l�iE#<�����3��m���}�Ƣ��GN.s�K}|Zm��ruO£���� (|]/��>�P�t���2m&��M��"��*�Zf ���#	�
�n��n(%1�����(���(O�8��/�Gsu��fw2T2p�
�)r?�G��Q6��^P
.n$��'|�g4c����t�2����bQ��r\���� M$�"�Hk~�q�D�՗z-hN�@�l�4��%�]+^�e׫��ӝ�����b{��6h��_ך�cd������������(����;�����a�l�t�@Q113gq���b����z;c����kC:�gs9��نM�q�����Mw�Q���ѽ����פ�{:�yV;���B�uR��4S��؀(:�q�W�K��T�B ��d\k4�~@(�ћU��C�#��D�^cК�ñ>*��a줂s
���,9���wfM�jY~�W��-��� ����L�t0�8�������{�^�5u%�D��"�L*#���^��!���(/M7� ��v�͢����ݹ>�{V�S�f���l0������{zS�?p����O��������?����K��g�Ɂ�k,�_������FhD�aU[�����~����{{`��a��a��7��"�N��������$:�8&c����$�r*r*�蘹���4��\�#����#h�8��W�
��W����3�غ�*M�-b�!=ns.����Ul��wm�[����w�S�Eܞ],�\�W&T/{��f@,�Ò���RH�bp�)����'�vb.��U�>�^��*���6_��U�����?�>�H��j����MU� �4q������?��������f�b�q������������?�|cES�����,��&��o����o��F{���/���L�1߸��}�8�?�j�/�7B���d���
�?Jp���+��ߍ���ď�o�S�W}�bk�4��4۔ŏλ��b�V���?���n�6��zTh��i�������\k�Z���&f�w�>������ W�v'��={YNuZV��er8���:>v�x��]�Rl1�¸^�������U��f�G�NW���]��:�W(������}S��wW.��69V�P�v��ɲ){6i[۶B�ԣ�D��FmS��!=��BS��_��k�1�J>�v��\�A �T�ЭN̬�q�fC�+Lx}�ˊ{�@�c�v��V������ތ�GC����=ǒ�B��ҵ��}�R���_�@\�A��W���C�� ������?���?����h����������?�������N�=_���,���`��U�G��m[�mNyy�a�J�=�SN�[Q�K�z�L�����CcAF��wV^sb?������U���M͟�a�&oy��]O����/��c��w`e�.��ߺ���ͭ�$��6y�{�)�7�B�>����<p�}�d.ʀR�X_
���f^��c���$/;����?���T4S��1��?���A���Wt4����8�X�A����������?/�?��4��?�O�㛢~��k���?��9���������O��	����7���Ԁ���#��y���	�?"�����/���o|�VQД������ ����������CP�A0 b������ga���?�D������?������?�lF���]�a����@�C#`���/�>����g9�I�y��j�o������Ɵ�ߘ�Yg6�Z�9�=��E���?���?7�sP���uRt�Y|����Qg��=Ic�'���9���L�WlG�/C"2F�����+�SS[ӣC���؜�vՒ.Z���:��r�l��e���_x���n�?{|U�༿����^.d��T:�)�lev�o􏇛w0��`u*�,%mڦp���޸���Yh��V���@�TfQ�Ju��E8�Y�.��O�k�j�B ;�B����p�a���EZ:v�{����N9k�1f��E�=��W����g�&@\���ku�2��� ����?��y����p����r!��<�������҂(r\������H�S"˦�(�,˱�D�C��z����78�?s7�O�σ�o�/����{w��/C?��ww���V����Go���kylx�r��a��q���k�.f����|�XO��raˣ�,�^�PXeXus{<��6�z�
q����rLȋe�/'�Н�r�M�E$h�Z�_&��If_І5��X�����=�)�8f�����t4���� �;px���C���@������������G�a�8����t�����`��@������Ā�������D���#�������������������������B�!�����������Y�~��|���#�C�����g񽳷L����|�������8?|3���o&�����x�Hκ5y�d�,������,��v�����kf����<��Q��ڛ��Yk�V_�K5�/�l#]��za�aݕ?|����4��9ao�x3*zt6m��}�Ǫ�̔�N��J��e���Ч�XwO!-����G|�td���0'�5�5�4r��J��t��u8=�?�eMg�q����C�<��c�ʲN�ۡ���-��۪pݒ���[��s|2Z7g>-M]����'��	���p����ux��e��9*]�����+�\����'�1e�6�P%�ߥP:V����ݒ>��j��2�_O����۹���0^��}梕3�mv4��O]%ծ�ږ��X�;��=��Nn�e �SA7�u��U.��r-%��$�N_妄k[��l��q��M��s�dI!F��z���)�Ͽ���n��� ���?��@���]������\�_"i:�*ɲ4�i6ʙ,⥘�D�ᓄgi�Is>�$��h>gE�f�$Ob*�3	�?~��?��+�?r������ق8��Ó8��"��0��?�#�%^?�Xc�T����vgmUI�I��[uƺ�N8/����T�>�}��Z��|(��,����v����A{{���)j������?�����������	p���W�?0��o������q����3��@�� ���/t4������(�����#���Bb���/Ā���#��i�������=���+�4 7GS�����M��r1�]6;���,��4`�����{��.�t���S���-q�8�NG��� ����k��Y͜��l�|�媥�e�L�j�V]�?O�۸c�u�u��t[�6��Q�ߎ׬������֦��҃�b��]���%������%	�����<��ԙ�'b������XS���cY2]�J�EκQJ���D��FY���{�ӝc���3�H���2aG�2Vμ�o���?��q��_�����?,�򿐁����G��U�C��o�o������1���E6����?�~`�$������=]�[��7��닾#�K݅�@!	�����q�&U	�l���f"�YA��Q�P�0�+kL/��sZ���VFӓ>`]k�O������<ߢK���/E�z[Y�i�����z�YAMe��ц��{ɫ#���_=YU4y���n�9vM����滍��F���@����t���j;>����y�/S��Ү#�^�����V,�5iC�[��k�����ߥQ�E��_�@\�A�b��������/d`���/�>����g9�������[����N�/����[�4_Z�|�J��P����ǿ���B~��~�{뤐O_���W=~w��RYZ�rf�cW��M&,����epȧ[�= ��<���p��m
R������u�F֯���j�դL��u�:EX(������www����>�����^.d��T:��.��Z�C�#�j�g���A<�fd��z3�L%�)��A�U39u�8`�׉�{��ӎL�eSs;}�Cw'R��6���f���3�0ҋv93�����˼\�uN�Y�2g!"[ӽ�:�Y���Cnݪ�K.�-J-�Jte�T�6��������/d �� �1���w����C�:p��J*O�!9��DLQ���(��Ȍ�D&�IA��/�|D�t��#�<$�~��U��5¯��*֫�-�Ex�egA����=�q)�g��9�vZ�s���ݩ5�)�t�[c����h��kӉ��n��t�
W�����8�Ƴ�$_)��z���vijb8럒�<2��Y���������X����ߍ����D`����3�����5�/O�O��w#4�����-M����S��&��o����o����?��ެ�cy6�82Ϥ8�2!%�OҜ�R*�RV�9I�96!91a8�g(!�.��4�S>���������� ��~e���7�s�+I��1��C?v:�m���V�o�y<���K���^ר:U����[��b�i����+Z�2;�X�{tN72����e�î���W�b�u5��ϳ��YQբ�F{�����}���0��o����� li���L������!���?�|�
�?�?j����? �����Ɗ���G�Y8�� ��!��ў�����_#4S�A�7�������?��Y�ۏ8��W��,��	`��a��Ѯ���7*��� �W���������Ѵ�C /���o����?����p�+*�������^�����ρ�o��&_��3��MД�����j@�A���?�<� ����6#�����/�������XDAS������5������������A����}�X�?���D���#��������������_P�!��`c0b�������������C.8p����9��n����o����o�����/p�c# ��Vٵ:��D������P/����7.��E�Ȥigy�ё�K��e\,r'�	�1�$l������Yl&�+�b���������O=� ��	�������ο-�����<ה��4+:YG�ހeͥ��wm]j����_�3��3��Ň��MT.
(/gpP�B���U�N%کJ:z�72�H*���9���\���m_�1�������'L���PMS�͆kx\�Ƴ�y�N&w8s6��)[!�O8���N�"�J���IFc�B8�+G�͘zC�W����s����l��u�(ge@���6��Iu���}���������y���C����u�^�?����?������w�� ��3��A�O�C����`�����0��?���@��������������z����w��?6���?��������:� ��c ����_/��t������9�F�?ARw�Oa����7�?.��(�t]�e���%8��lPh�����+������?���d�z�-�}�yH'ߐ$q�����I�ܡ�`�RMCg��f�2�]�C��M�G����o�M���������+�d�jԹx�v��}9jJBõmmأ5��@�V�j^��.s)l���-G�K�yJ�,��IK�`����Z˴�<wrC�|�b��oc�߅^�?���:� ��c ����_��t���)H�L�8�tS���d�`C?"���A�=!<4�#*�ɡ��(���5��A�Gw���Ȣ�w��=�xr�,��[����r�Y��:��v���z�9���N��N��`ڰz�a�բ�a!#���qw�-��=�ܠ��(h�"���`���0c��m0�FSߵ���4\�����?���0:|O��?��G��k���>���?J������?��_y�I� ����������V���?�0"�CT8�� �I$1N{�0�j��>u5}�L�̐@F��nD���A����������V�;��:��,���Q��܆J���9��ĥ�V��M���͗�GC�Oəݮw�zd���V��L����\�P��/�ZOp(���H�P�S%"���g~(�-9oRr�_T)/5����������-���\�E[�������hp��
���҄[�W�u�k���yrS3�ԉITw�_n���Fk~�������*���j��~��KrN�[��_��z���������疵��M���)�O��vqI�n�}��S9�y[@���+���ƽ���� �u�eT�Uy�sIn�pܤYG���e���p��_ua#4��,n�c�.��va�ϳ_:!N=�J|�Ob	[�sM��~p��3��J֦J:��5D��?a_{�RI�t�b6M(T�p��S����lA��!C5WeR܆�A�,v�ލg�k��LR�Wd�(�K<H�����[��_8��	����^��������?��/ ������wwh��_ր��ޠ-����~w�C`���u�3����W�?V�v�n����#!��X���������~��O�H엙�ї���������R���R�Q��ў�
�5�@��r�euQ�X�2�`�S�p�D�����tk�D4w�)b����e˜�K���
�]����KQx��|㣾��a3�Uo���/2i�\�ev2+k���Щ����r��k+R~���3Yf3{�kds�v��a��|Є�*��D�3�-"<�]c�#[7�T�t-!4Ϩ<_�<�l�RsF$e�w�I �K���bcFL$V��s�/p������o��������?��/��������wh���C�~�So*���E�?B>����m����7�o�/���>8Hx�e^���j��M�?����^�w�.�F���9mw�|�w{5ڟn^�]7�k[��-�GxGޭ<�� �/�~!a,�d�"�lh�6~�}7Ȕ>U����:�/����.o���|�6��"�DKی T�3+㾴i|ɶ���s�<��/�>2�8G���Q7PÝ��� M�%�cvD��*�|1Ȏ�y��s�g?}5���/�	{��茟��+��aTqw���*]��4�甴���"�Td���� <槈�<��ոL�5��{36u��ftI~�����@�oG�T���9�����	�6�V�����0��{���MR��0�R� w�N�?����pwQ��?����pw�;����8���!�Fc~k-�0�K{ad$M��G�;��4G��Z��̞1"F��	�{1���h�U�*�U����Q����O�A�sy�H���-v�.3&�OeZQ2��xS*���?LX�ݴ�Q��|�$s��-Oɸ�<L^��e�C�TCȦ#�>FO��ȥ+Xu���ȯr��I
�BB�1W����1��E(��_���{�@�����_`���՝�{���ZA���~��>�?�zP�E��ko���V�MX�e��؛F�*��]M7Э��5`�u+7$��UY�`�3u`�|�~c�5BA�˗�l �>�M4[��'s�amK��7.z`���F��-�e�PFp��Q�e�:�Vg̟���J�$2�w�7̺�N������ѵ�}c��:��oW�`��io��*AF��q�4[X��(�c�����xw�73���Q'Z5u�B�<K��$)�{xF��#Ȭ ��F� ��~��_@�w+�J����A�=��	���
@���O7����t�N���s�A��������?��4��z�3˧�(��B��A.�˙ƴ<�ݺ$�7<���`7-��_|ݝB���|��ʜ��k�w�$/��9����s�~��Q�j��%U��1$��J�k�6�s��.���;�1>�@�N�A]F|�Mԝ��e�00r��ł���f�����%^-�r��O���LJit��]���FM��)��<����������=���#�q����?� ��c�>�?����w�v�T���>�P�����?���?���G�_I��������ۗ��Y�;������'���A/�������h����>�;BO �����!���/��t��`'\? �������������E����\�������
@���@�����?�m�?�� ��c�^�?� ���ZA���� ��c�?������?����M�f����?������?��t��w��s����?����m�-�?���`�j���ݣ[�$��H�`5Vf����[���������ϙf܈s%t��ܻ�9A_�dY����'�:�2L��=7"k�S����$��:���e��2�+�@�\�l9'���މh��S�>/v���,�9�<X�4*v���ͥ(�[�^�qR_�qb3�U��K�Y��2;��5��c�To��e9��5
�)?�[ƙ,��=�5�9D������UE���y�E���4�k�sc�&#�ʖ�%d����+��ՂMYj����N=	$]`�2�BVl̈�$�*~0w{��E���[��C係��VЕ�ˣsU���n����}����?���t��Q�Db��P1��8�\*B��~4GC$0�j� "������~l?���8���?	�x����ĺ��O��|����jE�%os�x��]O��M�ԗh��J\��A�Tu�Ц)傹7som���G�a�عX��Z�O������f�w��T:!hOQ��e�4��-X��g|�E������Is������r��h_m�ݓ����p�G�;���-�O���@���h����������^�?M��?��h�������@�
���w���`��ZA��B�:�����?q���?[B_�t�v����g�?QP�i�����O���m���_P�k��?�9��������?��@ ���^�?������A����@���O ������� ��t��@T� ��c�^�?q���?������G�I@���r>��������V������R&�jx�����	L�ٿ��%���7���[;iO���[�l�{
��j�����g����A`�@�V���	'M�ds�9%�p8S���l"#��+xa�aD���s4gsmն4JWr�7�^�k~��8�}�61�t)�T��FH�-��f�9V��Nn]	Э�?�u��D_I��q��!�y���/M�zu����8^o�v���C���?��;���>�V#\��顊�j[R�1�	-�:ﵺzbSV���Lp��a4`!yGL��9&��`W����\����?B/�B��ώЩ�!P���������8� �����~��xDz^�Q��C��*F�1IE>I2>�h|�!CQ
� �)&���d<����?��>����O�0�˳)�����#d;�|����S����<Kms��s��"8��x3-3Je�.���$.\n���9��	)�̖c?���LN��3Lߤv�˯1qj�G�N���U|<�O��{?��OI=z~������7>�(M~w��a48�k���Ow��Uk��'�֟�ݧ8=T���p(��iHw�'o��te����BU����-Ƒ쪝��lϝ�١��LLk���鱫�*ہ���_��^~Dh(��U���.�e{��| A�i	�!�3d%B���m$�"��@�/>"�JA���v�_3=�ه����{Ͻu��9��{ιףȮ6	��r;2�he<j�j5%��3@��;�ߎ(j$�*l���/8���WD��?���w"ىܼq}5�
z�&/���R> ���Ն�{�]�8R�0ΝY�Q�~�m�ndW�ӗ���0���ڰ���6�,E"2r"		�L[���}I>/�w4;2۶i��<
Z����#�獵�6u��(��	�@����	����������N���ֆ�4��D��$ܗ���4���`t�PF�|]ٶ��]�1hJ�J#;d���Ui��W��x���n����j�FPDV��B����1m��:ԉ�=��	�N�˺�q5m�s�|Q�?����9���h*��#�J�?���챑,��4�B�3��(:�}� ���F�;�BY���Hq����ҝ`�w��N�wj�Y���S�?����?�!�R0�	8�7���� x�x	Է�o_����o?�si�/��5UuE-W2Z
I�Z[UQ$%c	�z
N�	E��6�+�6W�ZB��4�NC�dƅn|����~
���惯��G��������o�/C��x��@�q���b=mC��S�X!�AO�}�_�UAK�`�4�}�!\��qP���s��;��t�ܡ~�ag\\H�]��n]����k烺��C3��=��JPyiU�q����+xa����+��o��?��_���O����?��?��O�_�.��sy4jk�o���|'�S�;�fk��-'���c�M��#���W �lG.�x��>��OD_���'���_����;���{ot�O5կ��D�}�!���ֹk点��_	��#��kڦ��h�J0c(J;����º��夬��	Xmc�t�'���&2�n��tBK"HV�v �7D��_��W�+��g��������+ri�����=�� �� }��| ,��M�G7O���	}�������'����{z�Y��=���Ň���0^���U�q�$���Q�S�>6�v�ʱ8�B=�8xN��qp:������H����' ���Rf�/S�+|��zXf-��U�E���y>����h�(�sZ`z��E,SC��\oM�>�6����#Oٲ�dǠ@�f�:jɍ�՞�-�P��;l-xv��ѣ��+|����H�o�_�/�h"	Ah�y�/	%ը�\*������<c�\5>��^���0�I�pߚ�F麐�!���R���ΰ<ɸ27�d��O�8O��Z���"M[x�0��G6�W�7�N��w��.;4j&A�fIN��l0��� �Ѳޚ�+iU�Lc�R;��f��b�����0|_.���M�KM���� �qj�}BF��͋�)%
��QV�I�d���I̠�q���Z��6}M6���'�3 J"]{@�z�ɇH���c�R��Q��s�c���|��䤞�]�4��a�
���-�_�`.�p����%�'1����L��:1E�Rb�"�y�t���Au<^�d�J�="3�b����+�hʍ&jDB��	c�����z�q/���tV�"�T�e\#-�"�7��gRX�2�ׂG\D��fk�q���V5V�c(S�/���V��Dz���&K��Q�C�{�-�����E���s�Xv��f���cì7N�\�i7�F��˦�X�/�M9�|��uܝj��Dѹ~���v�T'�z/��pĢ�T:�6�i��3����,SN��d�5��f	(C��Y
)w�W��,�>�h�j���%bL��2lOUJ�Ӎ���3D��t�jc9Fl�3��̣1^뱒��19��Wu��,��$��{�c�r��̒&q
kL6ϒ�D+�v]v2��N���\��t��vpx�,����A�ML�"L�J�L�b�֒��^A�B�3Ut�č1�Ϋ�׌�[����ZA�a��d��6���;�#3f��B=~E�9��(�Gz�6o
֓��NXObc����gش�ϰ	h�LO�cG���بq�og�Dy�V{9��|��O���hيFE�	�R���c�����]Ja�8o�u۳D�M�*��$uS��R�ɇ����D�G�c�l��L�uo0�5�U��N�'�FZv�s�#�	*w���wV��Od�|����Ѧ��c���۪�H�B*��zY8�w�4�4{e�v�q�@��ZՍ�&�Ĩ�2�yfje'�)VZ�Ԥ5������B\O�y�.��Ql{o)�?X���K���:�]>�o=�}9\��ǫ�ja|�� �Ck��-����M���g���J���k��_���������W�/\9�|���͏�D"_:��O�>t��$�b�n�ǐ�oƻy���4)�4�����&/�X�K�[-�M�����Y�A���0��r^��t��~m8wea�+&�Z�i�A�/�>��zq�w�x'r�$V�vTӛ=�������b˂���9ճS�+'2���{>0��p�j�8e��As��<��K͑��Sy�l�ޠ;:b^����(��]�Q7U�N�Y%��<�ԺI`���"s���cV��e��>�UYO�әb�,R};.U�1����=5U��*6V�+�!�i<B�F�n�t���5���c�9aK@h:U�xj#��D�>r�
�!�����T�8-�������;�b�.,Q�~̶���%`�sUnVofD?kQR�mL�F*f=y��%|MJ��i��&�R/�~�&PIg��n"���F��a�@�4����ʽ)爪��l���E:NK&IT���&����T,�*y*9A�n��������]uz�2����޺ m��hÕ���h��"&�y��m ������no��Rk�~��-�k���S�������'N��|���%�Ϝ�@I�Z��/��m5�=:M��V_�@��^��;���$X�ǀ�'�"Y�R�v)�[Hg<��cyr�gDI�sN���kJ}T��af�r|���8e*���X4��s)���oBJrw<�)�0�a�X�Ow<mʱ�1���I�����{~��o�	���w�Նϖ{�VҴ�g�R�)u�[U���Jrt�3�^�9:�,K��AQfXuc���S1��@���9����&α�sl�?�q���꽟�7ު�1o�&z���=z���N��_�������^���LxoC�:m�y�BO�{����?��Y�@��f�����=�&�y���,v$B[��ۿ
��9���=a�j�5�"x�sz��A��%B)ޜkг��-p�����7�ߏ�u��G0��3A� =>�����W��s@��G���q��s�H6��>9n�F^� �!��]I��2����V��	�z�c��3� �Ӈ���{��o�-��䑼׀��"�8���Oxf�������C��4z�7Nۻ�؉q¯���X�m`��6��l`��6��v҇ � 