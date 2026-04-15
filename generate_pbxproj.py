#!/usr/bin/env python3
"""
Generates a valid project.pbxproj for the WarrantyVault Xcode project.

Scans the WarrantyVault/ source folder, builds the file graph, assigns
deterministic 24-hex identifiers, and writes project.pbxproj in the
exact format Xcode expects.

Run: python3 generate_pbxproj.py
"""
import hashlib
import os
from pathlib import Path

# --- Config --------------------------------------------------------------

PROJECT_DIR = Path(__file__).parent
SRC_ROOT = PROJECT_DIR / "WarrantyVault"
PROJ_FILE = PROJECT_DIR / "WarrantyVault.xcodeproj" / "project.pbxproj"

PROJECT_NAME = "WarrantyVault"
BUNDLE_ID = "com.warrantyvault.app"
DEPLOYMENT_TARGET = "17.0"
SWIFT_VERSION = "5.0"
ORG_NAME = "WarrantyVault"


def uid(label: str) -> str:
    """Deterministic 24-char uppercase hex identifier for a given label."""
    h = hashlib.sha1(label.encode()).hexdigest().upper()
    return h[:24]


# --- Scan sources --------------------------------------------------------

def walk_sources(root: Path):
    """Returns (swift_files, resources, groups)."""
    swift_files = []          # list[Path relative to project root]
    resources = []            # list[Path relative to project root]
    groups = {}               # rel_dir -> [child rel paths]

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        filenames.sort()
        rel_dir = Path(dirpath).relative_to(PROJECT_DIR)
        # Register this directory as a group (even if empty, Xcode expects it)
        if rel_dir not in groups:
            groups[rel_dir] = []

        for f in filenames:
            if f.startswith("."):
                continue
            rel = rel_dir / f
            groups[rel_dir].append(rel)
            if f.endswith(".swift"):
                swift_files.append(rel)
            elif f == "Contents.json":
                # Skip — these are inside xcassets, not added individually
                pass

        # Register xcassets folders as resources (treated as a single "file")
        for d in list(dirnames):
            if d.endswith(".xcassets"):
                rel_xc = rel_dir / d
                resources.append(rel_xc)
                groups[rel_dir].append(rel_xc)
                # Don't descend into xcassets — Xcode treats it as a single bundle
                dirnames.remove(d)

    return swift_files, resources, groups


# --- pbxproj emission ----------------------------------------------------

def file_type_for(path: Path) -> str:
    if path.suffix == ".swift":
        return "sourcecode.swift"
    if path.name.endswith(".xcassets"):
        return "folder.assetcatalog"
    if path.suffix == ".plist":
        return "text.plist.xml"
    return "file"


def is_resource(path: Path) -> bool:
    return path.name.endswith(".xcassets")


def emit_pbxproj(swift_files, resources, groups):
    # Pre-compute IDs
    proj_id    = uid("PROJECT_ROOT")
    main_group = uid("GROUP_ROOT")
    prod_group = uid("GROUP_PRODUCTS")
    src_group  = uid(f"GROUP:{PROJECT_NAME}")
    target_id  = uid("TARGET_APP")
    app_ref    = uid("FILEREF_APP_PRODUCT")
    sources_phase   = uid("PHASE_SOURCES")
    resources_phase = uid("PHASE_RESOURCES")
    frameworks_phase = uid("PHASE_FRAMEWORKS")
    proj_cfg_list    = uid("CFGLIST_PROJECT")
    tgt_cfg_list     = uid("CFGLIST_TARGET")
    cfg_proj_debug   = uid("CFG_PROJECT_DEBUG")
    cfg_proj_release = uid("CFG_PROJECT_RELEASE")
    cfg_tgt_debug    = uid("CFG_TARGET_DEBUG")
    cfg_tgt_release  = uid("CFG_TARGET_RELEASE")

    # IDs per file
    file_ref = {}
    build_ref = {}
    for f in swift_files + resources:
        file_ref[f] = uid(f"FILEREF:{f}")
        build_ref[f] = uid(f"BUILDREF:{f}")

    # IDs per group (directory)
    group_id = {}
    for d in groups:
        if d == Path(PROJECT_NAME):
            group_id[d] = src_group
        else:
            group_id[d] = uid(f"GROUP:{d}")

    lines = []
    lines.append("// !$*UTF8*$!")
    lines.append("{")
    lines.append("\tarchiveVersion = 1;")
    lines.append("\tclasses = {")
    lines.append("\t};")
    lines.append("\tobjectVersion = 56;")
    lines.append("\tobjects = {")
    lines.append("")

    # PBXBuildFile
    lines.append("/* Begin PBXBuildFile section */")
    for f in swift_files:
        lines.append(f"\t\t{build_ref[f]} /* {f.name} in Sources */ = "
                     f"{{isa = PBXBuildFile; fileRef = {file_ref[f]} /* {f.name} */; }};")
    for f in resources:
        lines.append(f"\t\t{build_ref[f]} /* {f.name} in Resources */ = "
                     f"{{isa = PBXBuildFile; fileRef = {file_ref[f]} /* {f.name} */; }};")
    lines.append("/* End PBXBuildFile section */")
    lines.append("")

    # PBXFileReference
    lines.append("/* Begin PBXFileReference section */")
    lines.append(f"\t\t{app_ref} /* {PROJECT_NAME}.app */ = "
                 f"{{isa = PBXFileReference; explicitFileType = wrapper.application; "
                 f"includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    for f in swift_files:
        lines.append(f"\t\t{file_ref[f]} /* {f.name} */ = "
                     f"{{isa = PBXFileReference; lastKnownFileType = {file_type_for(f)}; "
                     f"path = {f.name}; sourceTree = \"<group>\"; }};")
    for f in resources:
        lines.append(f"\t\t{file_ref[f]} /* {f.name} */ = "
                     f"{{isa = PBXFileReference; lastKnownFileType = {file_type_for(f)}; "
                     f"path = {f.name}; sourceTree = \"<group>\"; }};")
    lines.append("/* End PBXFileReference section */")
    lines.append("")

    # PBXFrameworksBuildPhase
    lines.append("/* Begin PBXFrameworksBuildPhase section */")
    lines.append(f"\t\t{frameworks_phase} /* Frameworks */ = {{")
    lines.append("\t\t\tisa = PBXFrameworksBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXFrameworksBuildPhase section */")
    lines.append("")

    # PBXGroup — root
    lines.append("/* Begin PBXGroup section */")
    lines.append(f"\t\t{main_group} = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    lines.append(f"\t\t\t\t{src_group} /* {PROJECT_NAME} */,")
    lines.append(f"\t\t\t\t{prod_group} /* Products */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")

    # Products group
    lines.append(f"\t\t{prod_group} /* Products */ = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    lines.append(f"\t\t\t\t{app_ref} /* {PROJECT_NAME}.app */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tname = Products;")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")

    # All other groups
    def group_child_ref(rel_child: Path, parent_dir: Path) -> str:
        """For a child of a group (either a file or a subdir), return its ID entry."""
        if rel_child in file_ref:
            return f"{file_ref[rel_child]} /* {rel_child.name} */"
        # subdir
        return f"{group_id[rel_child]} /* {rel_child.name} */"

    for d in sorted(groups.keys(), key=lambda p: str(p)):
        children = groups[d]
        # Add subdirectories that are themselves groups
        subdirs = [p for p in groups if p != d and p.parent == d]
        for sub in sorted(subdirs, key=lambda p: p.name.lower()):
            if sub not in children:
                children.append(sub)
        # Sort: folders first, then files, by name
        def sort_key(p):
            return (0 if p in groups else 1, p.name.lower())
        children = sorted(set(children), key=sort_key)

        gid = group_id[d]
        group_name = d.name if d.name else PROJECT_NAME
        path_line = f"\t\t\tpath = \"{d.name}\";" if d != Path(PROJECT_NAME) else f"\t\t\tpath = {PROJECT_NAME};"

        lines.append(f"\t\t{gid} /* {group_name} */ = {{")
        lines.append("\t\t\tisa = PBXGroup;")
        lines.append("\t\t\tchildren = (")
        for c in children:
            lines.append(f"\t\t\t\t{group_child_ref(c, d)},")
        lines.append("\t\t\t);")
        lines.append(path_line)
        lines.append("\t\t\tsourceTree = \"<group>\";")
        lines.append("\t\t};")

    lines.append("/* End PBXGroup section */")
    lines.append("")

    # PBXNativeTarget
    lines.append("/* Begin PBXNativeTarget section */")
    lines.append(f"\t\t{target_id} /* {PROJECT_NAME} */ = {{")
    lines.append("\t\t\tisa = PBXNativeTarget;")
    lines.append(f"\t\t\tbuildConfigurationList = {tgt_cfg_list};")
    lines.append("\t\t\tbuildPhases = (")
    lines.append(f"\t\t\t\t{sources_phase} /* Sources */,")
    lines.append(f"\t\t\t\t{frameworks_phase} /* Frameworks */,")
    lines.append(f"\t\t\t\t{resources_phase} /* Resources */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tbuildRules = (")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdependencies = (")
    lines.append("\t\t\t);")
    lines.append(f"\t\t\tname = {PROJECT_NAME};")
    lines.append(f"\t\t\tproductName = {PROJECT_NAME};")
    lines.append(f"\t\t\tproductReference = {app_ref};")
    lines.append("\t\t\tproductType = \"com.apple.product-type.application\";")
    lines.append("\t\t};")
    lines.append("/* End PBXNativeTarget section */")
    lines.append("")

    # PBXProject
    lines.append("/* Begin PBXProject section */")
    lines.append(f"\t\t{proj_id} /* Project object */ = {{")
    lines.append("\t\t\tisa = PBXProject;")
    lines.append("\t\t\tattributes = {")
    lines.append("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
    lines.append("\t\t\t\tLastSwiftUpdateCheck = 1500;")
    lines.append("\t\t\t\tLastUpgradeCheck = 1500;")
    lines.append("\t\t\t\tTargetAttributes = {")
    lines.append(f"\t\t\t\t\t{target_id} = {{")
    lines.append("\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;")
    lines.append("\t\t\t\t\t};")
    lines.append("\t\t\t\t};")
    lines.append("\t\t\t};")
    lines.append(f"\t\t\tbuildConfigurationList = {proj_cfg_list};")
    lines.append("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
    lines.append("\t\t\tdevelopmentRegion = en;")
    lines.append("\t\t\thasScannedForEncodings = 0;")
    lines.append("\t\t\tknownRegions = (")
    lines.append("\t\t\t\ten,")
    lines.append("\t\t\t\tBase,")
    lines.append("\t\t\t);")
    lines.append(f"\t\t\tmainGroup = {main_group};")
    lines.append(f"\t\t\tproductRefGroup = {prod_group};")
    lines.append("\t\t\tprojectDirPath = \"\";")
    lines.append("\t\t\tprojectRoot = \"\";")
    lines.append("\t\t\ttargets = (")
    lines.append(f"\t\t\t\t{target_id},")
    lines.append("\t\t\t);")
    lines.append("\t\t};")
    lines.append("/* End PBXProject section */")
    lines.append("")

    # Resources
    lines.append("/* Begin PBXResourcesBuildPhase section */")
    lines.append(f"\t\t{resources_phase} /* Resources */ = {{")
    lines.append("\t\t\tisa = PBXResourcesBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    for f in resources:
        lines.append(f"\t\t\t\t{build_ref[f]} /* {f.name} in Resources */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXResourcesBuildPhase section */")
    lines.append("")

    # Sources
    lines.append("/* Begin PBXSourcesBuildPhase section */")
    lines.append(f"\t\t{sources_phase} /* Sources */ = {{")
    lines.append("\t\t\tisa = PBXSourcesBuildPhase;")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\tfiles = (")
    for f in swift_files:
        lines.append(f"\t\t\t\t{build_ref[f]} /* {f.name} in Sources */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t};")
    lines.append("/* End PBXSourcesBuildPhase section */")
    lines.append("")

    # BuildConfigurations
    lines.append("/* Begin XCBuildConfiguration section */")

    # Project-level Debug
    lines.append(f"\t\t{cfg_proj_debug} /* Debug */ = {{")
    lines.append("\t\t\tisa = XCBuildConfiguration;")
    lines.append("\t\t\tbuildSettings = {")
    for k, v in sorted(project_common_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    for k, v in sorted(project_debug_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    lines.append("\t\t\t};")
    lines.append("\t\t\tname = Debug;")
    lines.append("\t\t};")

    # Project-level Release
    lines.append(f"\t\t{cfg_proj_release} /* Release */ = {{")
    lines.append("\t\t\tisa = XCBuildConfiguration;")
    lines.append("\t\t\tbuildSettings = {")
    for k, v in sorted(project_common_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    for k, v in sorted(project_release_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    lines.append("\t\t\t};")
    lines.append("\t\t\tname = Release;")
    lines.append("\t\t};")

    # Target Debug
    lines.append(f"\t\t{cfg_tgt_debug} /* Debug */ = {{")
    lines.append("\t\t\tisa = XCBuildConfiguration;")
    lines.append("\t\t\tbuildSettings = {")
    for k, v in sorted(target_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    lines.append("\t\t\t};")
    lines.append("\t\t\tname = Debug;")
    lines.append("\t\t};")

    # Target Release
    lines.append(f"\t\t{cfg_tgt_release} /* Release */ = {{")
    lines.append("\t\t\tisa = XCBuildConfiguration;")
    lines.append("\t\t\tbuildSettings = {")
    for k, v in sorted(target_settings().items()):
        lines.append(f"\t\t\t\t{k} = {v};")
    lines.append("\t\t\t};")
    lines.append("\t\t\tname = Release;")
    lines.append("\t\t};")

    lines.append("/* End XCBuildConfiguration section */")
    lines.append("")

    # ConfigurationList
    lines.append("/* Begin XCConfigurationList section */")

    lines.append(f"\t\t{proj_cfg_list} = {{")
    lines.append("\t\t\tisa = XCConfigurationList;")
    lines.append("\t\t\tbuildConfigurations = (")
    lines.append(f"\t\t\t\t{cfg_proj_debug} /* Debug */,")
    lines.append(f"\t\t\t\t{cfg_proj_release} /* Release */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append("\t\t\tdefaultConfigurationName = Release;")
    lines.append("\t\t};")

    lines.append(f"\t\t{tgt_cfg_list} = {{")
    lines.append("\t\t\tisa = XCConfigurationList;")
    lines.append("\t\t\tbuildConfigurations = (")
    lines.append(f"\t\t\t\t{cfg_tgt_debug} /* Debug */,")
    lines.append(f"\t\t\t\t{cfg_tgt_release} /* Release */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append("\t\t\tdefaultConfigurationName = Release;")
    lines.append("\t\t};")

    lines.append("/* End XCConfigurationList section */")

    lines.append("\t};")
    lines.append(f"\trootObject = {proj_id} /* Project object */;")
    lines.append("}")

    return "\n".join(lines) + "\n"


def project_common_settings():
    return {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
        "CLANG_CXX_LANGUAGE_STANDARD": "\"gnu++20\"",
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_ENABLE_OBJC_WEAK": "YES",
        "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
        "CLANG_WARN_BOOL_CONVERSION": "YES",
        "CLANG_WARN_COMMA": "YES",
        "CLANG_WARN_CONSTANT_CONVERSION": "YES",
        "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
        "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
        "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
        "CLANG_WARN_EMPTY_BODY": "YES",
        "CLANG_WARN_ENUM_CONVERSION": "YES",
        "CLANG_WARN_INFINITE_RECURSION": "YES",
        "CLANG_WARN_INT_CONVERSION": "YES",
        "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
        "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
        "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
        "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
        "CLANG_WARN_STRICT_PROTOTYPES": "YES",
        "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
        "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
        "CLANG_WARN_UNREACHABLE_CODE": "YES",
        "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
        "COPY_PHASE_STRIP": "NO",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "GCC_C_LANGUAGE_STANDARD": "gnu17",
        "GCC_NO_COMMON_BLOCKS": "YES",
        "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
        "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
        "GCC_WARN_UNDECLARED_SELECTOR": "YES",
        "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
        "GCC_WARN_UNUSED_FUNCTION": "YES",
        "GCC_WARN_UNUSED_VARIABLE": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": DEPLOYMENT_TARGET,
        "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
        "MTL_FAST_MATH": "YES",
        "SDKROOT": "iphoneos",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "SWIFT_VERSION": SWIFT_VERSION,
        "TARGETED_DEVICE_FAMILY": "\"1,2\"",
    }


def project_debug_settings():
    return {
        "DEBUG_INFORMATION_FORMAT": "dwarf",
        "ENABLE_TESTABILITY": "YES",
        "GCC_DYNAMIC_NO_PIC": "NO",
        "GCC_OPTIMIZATION_LEVEL": "0",
        "GCC_PREPROCESSOR_DEFINITIONS": "(\n\t\t\t\t\t\"DEBUG=1\",\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t)",
        "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
        "ONLY_ACTIVE_ARCH": "YES",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "\"DEBUG $(inherited)\"",
        "SWIFT_OPTIMIZATION_LEVEL": "\"-Onone\"",
    }


def project_release_settings():
    return {
        "DEBUG_INFORMATION_FORMAT": "\"dwarf-with-dsym\"",
        "ENABLE_NS_ASSERTIONS": "NO",
        "MTL_ENABLE_DEBUG_INFO": "NO",
        "SWIFT_COMPILATION_MODE": "wholemodule",
        "VALIDATE_PRODUCT": "YES",
    }


def target_settings():
    return {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "DEVELOPMENT_ASSET_PATHS": f"\"{PROJECT_NAME}/Preview\\ Content\"",
        "ENABLE_PREVIEWS": "YES",
        "GENERATE_INFOPLIST_FILE": "YES",
        "INFOPLIST_KEY_NSFaceIDUsageDescription": "\"WarrantyVault uses Face ID to unlock your vault.\"",
        "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
        "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
        "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "\"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\"",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "\"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\"",
        "LD_RUNPATH_SEARCH_PATHS": "(\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t\t\"@executable_path/Frameworks\",\n\t\t\t\t)",
        "MARKETING_VERSION": "1.0",
        "PRODUCT_BUNDLE_IDENTIFIER": BUNDLE_ID,
        "PRODUCT_NAME": f"\"$(TARGET_NAME)\"",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "SWIFT_VERSION": SWIFT_VERSION,
        "TARGETED_DEVICE_FAMILY": "\"1,2\"",
    }


# --- Main ----------------------------------------------------------------

if __name__ == "__main__":
    swift_files, resources, groups = walk_sources(SRC_ROOT)
    # Normalise ordering
    swift_files.sort(key=lambda p: str(p).lower())
    resources.sort(key=lambda p: str(p).lower())

    out = emit_pbxproj(swift_files, resources, groups)
    PROJ_FILE.parent.mkdir(parents=True, exist_ok=True)
    PROJ_FILE.write_text(out)
    print(f"Wrote {PROJ_FILE}")
    print(f"  {len(swift_files)} swift files, {len(resources)} resources, {len(groups)} groups")
