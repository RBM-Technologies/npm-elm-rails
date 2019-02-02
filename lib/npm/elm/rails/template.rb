require "pathname"

require "tilt/template"
require "elm-compiler"

module Npm
  module Elm
    module Rails
      class Template < Tilt::Template

        class << self
          attr_accessor :debug
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
          Dir.chdir(elm_json_root) do
            ::Elm::Compiler.compile(file_with_debug, elm_path: self.class.elm_path)
          end
        end

        private

        def file_with_debug
          # --debug, which enables the time-traveling debugger, has a known bug
          #
          # elm: Map.!: given key is not an element in the map
          # CallStack (from HasCallStack):
          #   error, called at libraries/containers/Data/Map/Internal.hs:603:17 in containers-0.5.10.2:Data.Map.Internal
          #
          # self.class.debug ? [file, '--debug'] : file
          self.class.debug ? [file] : file
        end

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
