# -*- mode: makefile -*-
# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Definitions for installing Certificate Authority (CA) certificates
#

define all-files-under
$(patsubst ./%,%, \
  $(shell  \
          find $(1) -type f) \
 )
endef

LOCAL_BUILD_DIR := $(PRODUCT_OUT)/obj/ETC/ridon-system/build/certs

# $(1): module name
# $(2): source file
# $(3): destination directory
define include-prebuilt-with-destination-directory
include $$(CLEAR_VARS)
$(eval LOCAL_HASH := $(shell openssl x509 -inform PEM -subject_hash_old -in $(2) | head -1))
$(eval LOCAL_FILENAME := $(LOCAL_BUILD_DIR)/$(LOCAL_HASH).0)
$(shell mkdir -p $(LOCAL_BUILD_DIR))
$(shell cat $(2) > $(LOCAL_FILENAME))
$(shell openssl x509 -inform PEM -text -in $(2) -out /dev/null >> $(LOCAL_FILENAME))
$(info Generating cert $(2) into $(LOCAL_FILENAME))

LOCAL_MODULE := $(1)-cacert-$(LOCAL_HASH).0
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Certs.mk
LOCAL_MODULE_STEM := $(LOCAL_HASH).0
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(3)

$(eval XTOPDIR := $(shell (pwd) ))
LOCAL_SRC_FILES := ../../$(patsubst $(XTOPDIR)/%,%,$(LOCAL_FILENAME))

include $$(BUILD_PREBUILT)
endef


ridonsourcecerts := $(call all-files-under,$(LOCAL_PATH)/certs)

ridoncerts_target_directory := $(TARGET_OUT)/etc/security/cacerts

$(foreach cacert, $(ridonsourcecerts), $(eval $(call include-prebuilt-with-destination-directory,target,$(cacert),$(ridoncerts_target_directory))))

ridoncerts := $(call all-files-under,$(LOCAL_BUILD_DIR))
ridoncerts_target := $(addprefix $(ridoncerts_target_directory)/,$(foreach cacert,$(ridoncerts),$(notdir $(cacert))))
.PHONY: ridoncerts_target
ridoncerts: $(ridoncerts_target)

# This is so that build/target/product/core.mk can use ridoncerts in PRODUCT_PACKAGES
ALL_MODULES.ridoncerts.INSTALLED := $(ridoncerts_target)

ridoncerts_host_directory := $(HOST_OUT)/etc/security/cacerts
$(foreach cacert, $(ridonsourcecerts), $(eval $(call include-prebuilt-with-destination-directory,host,$(cacert),$(ridoncerts_host_directory))))

ridoncerts_host := $(addprefix $(ridoncerts_host_directory)/,$(foreach cacert,$(ridoncerts),$(notdir $(cacert))))
.PHONY: ridoncerts-host
ridoncerts-host: $(ridoncerts_host)
