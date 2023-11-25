-- Define the function to download a file
function download(url, path)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
    else
        print("Failed to download " .. url)
    end
end

-- Define the function to clone a repository
function clone(repo, dest)
    local repo_api_url = "https://api.github.com/repos/" .. repo .. "/git/trees/master?recursive=1"
    local response = http.get(repo_api_url)
    if response then
        local data = textutils.unserializeJSON(response.readAll())
        response.close()
        for _, file in ipairs(data.tree) do
            if file.type == "blob" then
                local file_url = "https://raw.githubusercontent.com/" .. repo .. "/master/" .. file.path
                local dest_path = fs.combine(dest, file.path)
                download(file_url, dest_path)
            end
        end
    else
        print("Failed to clone " .. repo)
    end
end

-- Check if a repository was provided
if arg[1] then
    -- Use the clone function with the provided repository
    clone(arg[1])
else
    print("Please provide a repository to clone.")
end