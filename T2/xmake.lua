add_requires("boost 1.90.0", {configs = {
    all        = false,
    asio       = true,
    date_time  = true,
    filesystem = true,
    thread     = true,
}})
add_requires("qt5core 5.15.2", {configs = {shared = true}})

target("hkxcmpr", function()
    set_kind("binary")
    set_languages("c++17")

    add_rules("qt.console")

    add_files(
        "*.cpp",
        "AnimData/*.cpp",
        "AnimSetData/*.cpp",
        "src/*.cpp",
        "src/hkx/**.cpp",
        "src/utilities/*.cpp"
    )

    add_includedirs(".")

    add_defines(
        "_CRT_SECURE_NO_DEPRECATE",
        "_SCL_SECURE_NO_WARNINGS"
    )

    add_packages("boost")

    add_cxflags("/MP", {force = true})

    if is_mode("debug") then
        set_optimize("none")
        set_symbols("debug")
        add_ldflags("/STACK:10000000,10000", "/HEAP:10000000,10000", {force = true})
    else
        set_optimize("fastest")
        set_policy("build.optimization.lto", true)
        add_cxflags("/Gy", "/Oi", {force = true})
        add_ldflags("/OPT:ICF", "/OPT:REF", {force = true})
        add_forceincludes("Global.h")
    end

    after_install(function(target)
        local install_dir = path.join(target:installdir(), "bin")

        local rar_url  = "https://github.com/ShikyoKira/Project-New-Reign---Nemesis-Sub-tool/releases/download/v0.82/HKX.Extractor.rar"
        local rar_path = os.tmpfile() .. ".rar"
        local tmp_dir  = os.tmpdir() .. "/hkx_extracted"

        print("Downloading HKX.Extractor.rar ...")
        os.execv("curl", {"-L", "-o", rar_path, rar_url})

        print("Extracting HKX.Extractor.rar ...")
        os.mkdir(tmp_dir)

        local seven_zip = import("lib.detect.find_tool")("7z") or import("lib.detect.find_tool")("7za")
        assert(seven_zip, "7z not found. please install 7-zip.")
        os.execv(seven_zip.program, {"x", rar_path, "-o" .. tmp_dir, "-y"})

        -- Copy .hkx / .txt to originals/
        os.mkdir(install_dir .. "/originals/1st")
        os.mkdir(install_dir .. "/originals/3rd")
        for _, f in ipairs(os.files(tmp_dir .. "/**.hkx")) do
            os.cp(f, install_dir .. "/originals/")
        end
        for _, f in ipairs(os.files(tmp_dir .. "/**.txt")) do
            os.cp(f, install_dir .. "/originals/")
        end
        -- 1st / 3rd dir
        local dir_1st = os.dirs(tmp_dir .. "/**/1st")[1]
        local dir_3rd = os.dirs(tmp_dir .. "/**/3rd")[1]
        if dir_1st then os.cp(dir_1st, install_dir .. "/originals/1st") end
        if dir_3rd then os.cp(dir_3rd, install_dir .. "/originals/3rd") end

        -- hkxcmd.exe
        local hkxcmd = os.files(tmp_dir .. "/hkxcmd.exe")[1]
        if hkxcmd then os.cp(hkxcmd, install_dir .. "/") end

        -- Empty dir
        os.mkdir(install_dir .. "/edits")
        os.mkdir(install_dir .. "/mod")

        os.rm(rar_path)
        os.rm(tmp_dir)
    end)
end)
