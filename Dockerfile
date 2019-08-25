FROM monogramm/docker-erpnext-ext:11-alpine

# Build environment variables
ENV DOCKER_TAG=travis \
    DOCKER_VCS_REF=${TRAVIS_COMMIT} \
    DOCKER_BUILD_DATE=${TRAVIS_BUILD_NUMBER}

# Copy the whole repository to app folder
COPY --chown=frappe:frappe . "/home/$FRAPPE_USER"/frappe-bench/apps/erpnext_ocr
# Add the docker test script
ADD docker_test.sh /.docker_test.sh

RUN set -ex; \
    sudo chmod 755 /.docker_test.sh; \
    sudo apk add --update \
        ghostscript \
        imagemagick \
        imagemagick-dev \
        tesseract-ocr \
    ; \
    sudo sed -i \
        -e 's/rights="none" pattern="PDF"/rights="read" pattern="PDF"/g' \
        /etc/ImageMagick*/policy.xml \
    ; \
    sudo mkdir -p "/home/$FRAPPE_USER"/frappe-bench/logs; \
    sudo touch "/home/$FRAPPE_USER"/frappe-bench/logs/bench.log; \
    sudo chmod 777 \
        "/home/$FRAPPE_USER"/frappe-bench/logs \
        "/home/$FRAPPE_USER"/frappe-bench/logs/* \
    ; \
    echo "Manually installing app for CI (not needed normally)"; \
    ls -al apps/erpnext_ocr; \
    test "$FRAPPE_BRANCH" = "v10.x.x" \
        && ./env/bin/pip install -q -e "apps/erpnext_ocr" --no-cache-dir \
    ; \
    test ! "$FRAPPE_BRANCH" = "v10.x.x" \
        && ./env/bin/pip3 install -q -e "apps/erpnext_ocr" --no-cache-dir \
        && bench build --app erpnext_ocr \
    ;
