target("ProjectNewReignNemesis", function ()
    set_kind("binary")
    set_languages("c++17")
    add_cxflags("/EHa", "/clr", {force = true})
    add_cxflags(
        "/FUSystem.dll",
        "/FUSystem.Data.dll",
        "/FUSystem.Drawing.dll",
        "/FUSystem.Windows.Forms.dll",
        "/FUSystem.Xml.dll",
        {force = true}
    )
    add_defines("UNICODE", "_UNICODE")
    add_files("GUI Form.cpp")
    add_ldflags("/SUBSYSTEM:WINDOWS", "/ENTRY:main", {force = true})
    if is_mode("debug") then
        add_defines("_DEBUG")
        set_optimize("none")
        set_symbols("debug")
    else
        add_defines("NDEBUG")
        set_optimize("faster")
    end
end)
