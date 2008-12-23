module TestHelper

    #Helper method for file-based comparison tests.
    #
    #Looks in "data/" directory for files named "inputXXX",
    #substitutes "input" with baseName and loads the contents
    #of "inputXXX" file into the "input" variable and the
    #contents of "baseNameXXX" into the "result" variable.
    #
    #Then it calls the block with input and result as parameters.
    def test_files(baseName, &action)
        Dir.glob(File.dirname(__FILE__) + "/data/input*").each do |filename|
            resultname = filename.gsub(/input(.*)/, "#{baseName}\\1")
            #exclude backup files
            if not resultname.include?("~")
                input_file = File.new(filename, "r")
                input = input_file.read
                if File.exists?(resultname)
                    result_file = File.new(resultname, "r")
                    result = result_file.read

                    yield(input, result, resultname)
                end
            end
        end
    end
end
