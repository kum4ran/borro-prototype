#!/usr/bin/env python3
"""One-off patch: add BorroTests (unit) and BorroUITests targets to Borro.xcodeproj.

Keeps the app target, bundle id, team and signing untouched. Tests live in synchronized
folders Tests/BorroTests and Tests/BorroUITests, so new test files compile automatically.
"""
import re, uuid

P = "Borro.xcodeproj/project.pbxproj"
S = "Borro.xcodeproj/xcshareddata/xcschemes/Borro.xcscheme"
APP_TARGET = "3A54A323AFB041E0A068F1C2"
PROJECT = "551E524763D3452C85D6DE2B"
MAIN_GROUP = "876CAB805F044B338432FFB7"
PRODUCTS = "B3CD94BFDF4F45BF8536D2C9"

def oid(): return uuid.uuid4().hex[:24].upper()

src = open(P).read()
if "BorroTests" in src:
    raise SystemExit("already patched")

targets = []
for name, kind, folder in [("BorroTests", "unit", "Tests/BorroTests"), ("BorroUITests", "ui", "Tests/BorroUITests")]:
    t = dict(name=name, kind=kind, folder=folder, target=oid(), product=oid(), group=oid(), sources=oid(),
             frameworks=oid(), resources=oid(), dep=oid(), proxy=oid(), cfg=oid(), dbg=oid(), rel=oid())
    targets.append(t)

def section(name, body):
    global src
    marker = f"/* End {name} section */"
    if marker in src:
        src = src.replace(marker, body + marker)
    else:
        src = src.replace("/* Begin PBXFileReference section */",
                          f"/* Begin {name} section */\n{body}/* End {name} section */\n\n/* Begin PBXFileReference section */")

for t in targets:
    product_type = "com.apple.product-type.bundle.unit-test" if t["kind"] == "unit" else "com.apple.product-type.bundle.ui-testing"
    section("PBXFileReference", f'\t\t{t["product"]} /* {t["name"]}.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {t["name"]}.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};\n')
    section("PBXFileSystemSynchronizedRootGroup", f'\t\t{t["group"]} /* {t["name"]} */ = {{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\tpath = {t["folder"]};\n\t\t\tsourceTree = "<group>";\n\t\t}};\n')
    for kind, key in [("PBXFrameworksBuildPhase", "frameworks"), ("PBXResourcesBuildPhase", "resources"), ("PBXSourcesBuildPhase", "sources")]:
        label = {"frameworks": "Frameworks", "resources": "Resources", "sources": "Sources"}[key]
        section(kind, f'\t\t{t[key]} /* {label} */ = {{\n\t\t\tisa = {kind};\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};\n')
    section("PBXContainerItemProxy", f'\t\t{t["proxy"]} /* PBXContainerItemProxy */ = {{\n\t\t\tisa = PBXContainerItemProxy;\n\t\t\tcontainerPortal = {PROJECT} /* Project object */;\n\t\t\tproxyType = 1;\n\t\t\tremoteGlobalIDString = {APP_TARGET};\n\t\t\tremoteInfo = Borro;\n\t\t}};\n')
    section("PBXTargetDependency", f'\t\t{t["dep"]} /* PBXTargetDependency */ = {{\n\t\t\tisa = PBXTargetDependency;\n\t\t\ttarget = {APP_TARGET} /* Borro */;\n\t\t\ttargetProxy = {t["proxy"]} /* PBXContainerItemProxy */;\n\t\t}};\n')
    section("PBXNativeTarget", f'''\t\t{t["target"]} /* {t["name"]} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {t["cfg"]} /* Build configuration list for PBXNativeTarget "{t["name"]}" */;
\t\t\tbuildPhases = (
\t\t\t\t{t["sources"]} /* Sources */,
\t\t\t\t{t["frameworks"]} /* Frameworks */,
\t\t\t\t{t["resources"]} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{t["dep"]} /* PBXTargetDependency */,
\t\t\t);
\t\t\tfileSystemSynchronizedGroups = (
\t\t\t\t{t["group"]} /* {t["name"]} */,
\t\t\t);
\t\t\tname = {t["name"]};
\t\t\tpackageProductDependencies = (
\t\t\t);
\t\t\tproductName = {t["name"]};
\t\t\tproductReference = {t["product"]} /* {t["name"]}.xctest */;
\t\t\tproductType = "{product_type}";
\t\t}};
''')
    host = ('\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";\n\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/Borro.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Borro";\n'
            if t["kind"] == "unit" else '\t\t\t\tTEST_TARGET_NAME = Borro;\n')
    for cfg_id, cfg_name in [(t["dbg"], "Debug"), (t["rel"], "Release")]:
        section("XCBuildConfiguration", f'''\t\t{cfg_id} /* {cfg_name} */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
{host}\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.borro.prototype.{t["name"]};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = {cfg_name};
\t\t}};
''')
    section("XCConfigurationList", f'''\t\t{t["cfg"]} /* Build configuration list for PBXNativeTarget "{t["name"]}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{t["dbg"]} /* Debug */,
\t\t\t\t{t["rel"]} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
''')
    # project target list
    src = re.sub(r"(targets = \(\n(?:\t\t\t\t.*\n)*?)(\t\t\t\);)", lambda m: m.group(1) + f"\t\t\t\t{t['target']} /* {t['name']} */,\n" + m.group(2), src, count=1)
    # groups
    src = src.replace(f"\t\t\t\tC032419A58FE4EBAB38C80A6 /* Borro */,\n\t\t\t\t{PRODUCTS} /* Products */,",
                      f"\t\t\t\tC032419A58FE4EBAB38C80A6 /* Borro */,\n\t\t\t\t{t['group']} /* {t['name']} */,\n\t\t\t\t{PRODUCTS} /* Products */,")
    src = src.replace("\t\t\t\tC0CA643664F745A8A0E839C8 /* Borro.app */,\n",
                      f"\t\t\t\tC0CA643664F745A8A0E839C8 /* Borro.app */,\n\t\t\t\t{t['product']} /* {t['name']}.xctest */,\n")
open(P, "w").write(src)

scheme = open(S).read()
entries = "".join(f'''         <TestableReference skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{t["target"]}"
               BuildableName = "{t["name"]}.xctest"
               BlueprintName = "{t["name"]}"
               ReferencedContainer = "container:Borro.xcodeproj">
            </BuildableReference>
         </TestableReference>
''' for t in targets)
scheme = scheme.replace("      <Testables>\n      </Testables>", f"      <Testables>\n{entries}      </Testables>")
open(S, "w").write(scheme)
print("added", [t["name"] for t in targets])
