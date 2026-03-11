add_requires("qt5widgets", {configs = {shared = true}})

target("ProjectNewReignQtGUI", function ()
    set_kind("binary")
    set_languages("c++17")

    add_rules("qt.widgetapp")

    add_files(
        "./**.cpp",
        "./**.h",
        "./ProjectNewReignQtGUI.ui",
        "./ProjectNewReignQtGUI.qrc"
    )

    add_includedirs(".")
    add_files("EditDropBox.h", "OriginalDropBox.h")

    add_defines("UNICODE", "_UNICODE", "WIN32", "WIN64")

    add_packages("qt5widgets")

    if is_mode("debug") then
        set_runtimes("MDd")
    else
        set_runtimes("MD")
    end

    if is_plat("windows") then
        add_ldflags("/SUBSYSTEM:WINDOWS", {force = true})
    end
end)
