#!/usr/bin/env bash

GRAILS_VERSIONS="grails_3_3"
TEMPLATE_FOLDER="./functional-test-app"
TEMPLATE_FILES="/grails-app/conf/application.groovy"
S2_QUICKSTART_FILES="/grails-app/domain/com/testapp/TestRole.groovy /grails-app/domain/com/testapp/TestUser.groovy /grails-app/domain/com/testapp/TestUserTestRole.groovy /grails-app/domain/com/testapp/TestRequestmap.groovy src/main/groovy/com/testapp/TestUserPasswordEncoderListener.groovy"

rm -rf $TEMPLATE_FOLDER/build
rm -rf $TEMPLATE_FOLDER/.gradle

cd $TEMPLATE_FOLDER
./gradlew deleteArtefacts
./gradlew copyArtefacts
cd ..

curl -s http://get.sdkman.io | bash
echo sdkman_auto_answer=true > ~/.sdkman/etc/config
echo "source \"$HOME/.sdkman/bin/sdkman-init.sh\""
source "$HOME/.sdkman/bin/sdkman-init.sh"

GRADLE_PROPERTIES_FILE=gradle.properties

function getProperty {
    PROP_KEY=$1
    PROP_VALUE=`cat $GRADLE_PROPERTIES_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
    echo $PROP_VALUE
}

for grailsVersion in $GRAILS_VERSIONS; do
    rm -rf $TEMPLATE_FOLDER/$grailsVersion/build
    rm -rf $TEMPLATE_FOLDER/$grailsVersion/.gradle

    GRAILS_VERSION=$(getProperty "grailsVersion")

    sdk install grails $GRAILS_VERSION

    echo "sdk use grails $GRAILS_VERSION"

    sdk use grails $GRAILS_VERSION

    for file in $S2_QUICKSTART_FILES; do
        if [ -f "$TEMPLATE_FOLDER/$grailsVersion$file" ];
        then
            rm $TEMPLATE_FOLDER/$grailsVersion$file
        fi
    done
    cd $TEMPLATE_FOLDER/$grailsVersion
    grails s2-quickstart com.testapp TestUser TestRole TestRequestmap --salt
    cd ../..

    for file in $TEMPLATE_FILES; do
        cp $TEMPLATE_FOLDER$file $TEMPLATE_FOLDER/$grailsVersion$file
    done
done

