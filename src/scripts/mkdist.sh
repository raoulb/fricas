#!/bin/sh

SRCDIR=""
if grep '^abs_srcdir = ' Makefile > /dev/null ; then
   SRCDIR=$(grep '^abs_srcdir = ' Makefile | sed 's,^abs_srcdir = ,,')
   echo SRCDIR="$SRCDIR"
   if [ ! -d "$SRCDIR" ] ; then
      SRCDIR=""
   elif [ ! -r "$SRCDIR"/README ] ; then
      SRCDIR=""
   fi
fi
if [ -z "$SRCDIR" ] ; then
   echo "Unable to find source directory"
   exit 1
fi

copy_lisp=""
copy_gphts=""
copy_phts=""
NOWEB_TARBALL=""
GCL_DIST=""

while test $# -gt 0 ; do
   opt=$1
   case ${opt} in
      --copy_lisp)
        copy_lisp=y
        ;;
      --copy_gphts)
        copy_gphts=y
        ;;
      --copy_phts)
        copy_phts=y
        copy_gphts=y
        ;;
      --copy_noweb=*)
        NOWEB_TARBALL=`echo ${opt} | sed 's,--copy_noweb=,,'`
        if [ ! -f "${NOWEB_TARBALL}" ] ; then
           echo The file "${NOWEB_TARBALL}" does not exist
           exit 1
        fi
        ;;
      --copy_gcl=*)
        GCL_DIST=`echo ${opt} | sed 's,--copy_gcl=,,'`
        if [ ! -d "${GCL_DIST}" ] ; then
           echo The directory "${GCL_DIST}" does not exist
           exit 1
        fi
        ;;
      --copy_help=*)
        HELP_DIR=`echo ${opt} | sed 's,--copy_help=,,'`
        if [ ! -d "${HELP_DIR}" ] ; then
            echo The directory "${HELP_DIR}" does not exist
            exit 1
        fi
        ;;
      *)
        echo Unrecognized option "${opt}"
        exit 1
        ;;
   esac
   shift
done

echo copy_lisp=\"${copy_lisp}\"
echo copy_gphts=\"${copy_gphts}\"
echo copy_phts=\"${copy_phts}\"
echo NOWEB_TARBALL=\"${NOWEB_TARBALL}\"
echo GCL_DIST=\"${GCL_DIST}\"
echo HELP_DIR=\"${HELP_DIR}\"

clean_svn () {
    find $1 -name .svn -type d -exec rm -rf {} \+
}

# copy sources
cp -r $SRCDIR dist
cd dist || exit 1
clean_svn .


# copy noweb tarball
if [ ! -z "${NOWEB_TARBALL}" ] ; then
   mkdir zips
   cp "${NOWEB_TARBALL}" zips
fi

# copy gcl
if [ ! -z "${GCL_DIST}" ] ; then
   cp -r "${GCL_DIST}" gcl
   clean_svn gcl
fi

# copy databases and algebra bootstrap files
if [ ! -z "${copy_lisp}" ]; then
   (cd ../src/algebra; ls -d *.NRLIB | sed 's,\.NRLIB$,,' ) > ../nrlst
   for A in $(cat ../nrlst); do 
      cp ../src/algebra/${A}.NRLIB/${A}.lsp src/algebra/${A}.lsp
   done
   cp ../src/algebra/*.daase src/share/algebra
   cp ../src/algebra/libdb.text src/share/algebra
   cp ../src/algebra/comdb.text src/share/algebra
   cp -r ../src/algebra/USERS.DAASE src/share/algebra
   cp -r ../src/algebra/DEPENDENTS.DAASE src/share/algebra
   touch src/algebra/use_lisp
fi
