module Versioneer
  class Helpers
    class << self

      # Generic

      def lines?(input)
        num_of_lines(input) > 0
      end

      def num_of_lines(input)
        return 0 unless input.is_a? String and not input.empty?
        input.chomp.split("\n").size
      end

      # Platform Specific

      def windows?
        Gem.respond_to? :win_platform? and Gem.send(:win_platform?)
      end

      def platform
        return :windows if windows?
        :unix
      end

      def cl_no_stdout
        {
            :unix => '>/dev/null',
            :windows => '>nul'
        }.fetch(platform)
      end

      def cl_no_stderr
        {
            :unix => '2>/dev/null',
            :windows => '2>nul'
        }.fetch(platform)
      end

      def cl_silence
        {
            :unix => '>/dev/null 2>&1',
            :windows => '>nul 2>&1'
        }.fetch(platform)
      end

    end
  end
end
