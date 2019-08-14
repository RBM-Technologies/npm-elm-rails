require "pathname"

require "tilt/template"
require "elm-compiler"

module Npm
  module Elm
    module Rails
      class Template < Tilt::Template

        class << self
          attr_accessor :debug, :optimize
        end

        self.default_mime_type = "application/javascript"

        def self.elm_path
          @elm_path ||= "#{`npm bin`.strip}/elm make"
        end

        def self.elm_path=(path)
          @elm_path = path
        end

        def prepare
          # do nothing: no prep needed
        end

        def evaluate(scope, _locals, &_block)
          puts "npm-elm-rails 1"
          blah = Dir.chdir(elm_json_root) do
            ::Elm::Compiler.compile(
              file,
              elm_path: self.class.elm_path,
              debug: self.class.debug,
              optimize: self.class.optimize
            )
          end
          puts "npm-elm-rails 2"
          blah
        end

        private

        def elm_json_root
          dir = Pathname.new(file).dirname
          loop do
            elm_json = dir + "elm.json"
            return dir.to_s if elm_json.exist?

            fail "Could not find elm.json" if dir.to_s == "/"
            dir = dir.parent
          end
        end
      end
    end
  end
end
