function love.load(args)

    if #args > 0 then
        local script = args[1]
        local chunk, err = loadfile(script)
        if chunk then
            chunk()
            if love.load then
                love.load()
            end
        else
            print("Error loading file:", err)
        end
    else
        print("no script provided to run")
    end

end
