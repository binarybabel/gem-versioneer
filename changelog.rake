namespace :changelog do

  ### Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # How to determine current project version, prompting user if nil result
  #   - Versioneer may be helpful: `gem install versioneer` - Docs: https://git.io/versioneer
  #   - Or you can try accessing your app/lib version constant
  version_lambda = lambda { `versioneer print`.chomp }
  # Changelog file to read/write
  changelog_file = 'CHANGELOG.md'
  # List of shell commands to try to determine previously released commit hash...
  #   - the first non-empty command result is accepted
  #   - changelog will be built from this reference to current HEAD
  changelog_ref_sources = ['git describe --abbrev=0 --tags', 'git rev-list HEAD | tail -n 1']
  # Filter and format commit subjects for the changelog
  changelog_line_filter = lambda do |line|
    case line
      when /release|merge/i
        nil
      when /bug|fix/i
        '* __`!!!`__ ' + line
      when /add|support|ability/i
        '* __`NEW`__ ' + line
      when /remove|deprecate/i
        '* __`-!-`__ ' + line
      else
        '* __`~~~`__ ' + line
    end
  end

  ### Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  desc 'Generate changelog for current version (from last tagged release)'
  task :update do
    puts '== CHANGELOG:UPDATE =='
    puts '** What new version are you documenting?'
    current_version = version_lambda.call
    if current_version and not current_version.empty?
      current_version = ::Gem::Version.new(current_version).release.to_s
      puts 'Leave blank to use the suggestion, or enter a version number:'
      print "Version[ #{current_version} ] ??  "
    else
      puts 'Please enter a version number:'
      print 'Version??  '
    end
    input = STDIN.gets.strip
    if input.empty? and not current_version
      raise 'ERROR: You did not enter a version.'
    elsif not input.empty?
      current_version = input
    end

    changelog_ref = ''
    changelog_ref_sources.each do |cmd|
      changelog_ref = %x{#{cmd} 2> /dev/null}.chomp
      break unless changelog_ref.empty?
    end
    raise 'Failed to determine base git reference for changelog.' if changelog_ref.empty?

    header = ''
    footer = ''
    if File.file?(changelog_file)
      File.open(changelog_file, 'r') do |f|
        in_header = true
        f.each_line do |line|
          if !in_header or line.match(/^##/)
            in_header = false
            footer << line
          else
            header << line
          end
        end
      end
    end

    content = "### #{current_version} (#{DateTime.now.strftime('%Y-%m-%d')})\n\n"
    gitlog = %x{git log #{changelog_ref}...HEAD --pretty=format:'%s' --reverse}
    raise gitlog.to_s if $?.exitstatus > 0
    gitlog.chomp.split("\n").each do |line|
      line = changelog_line_filter.call(line.chomp)
      content << line + "\n" if line
    end
    content << "\n\n"

    puts "** Writing to #{changelog_file}"
    puts
    puts content.chomp
    File.write(changelog_file, header + content + footer)
    puts '== ALL DONE =='
  end

  desc 'Print changelog to console'
  task :print do
    if File.file?(changelog_file)
      File.open(changelog_file, 'r') do |f|
        f.each_line do |line|
          puts line
        end
      end
    else
      STDERR.puts("Sorry, #{changelog_file} does not exist.")
      STDERR.puts("Use `rake changelog:update` to start a new file.")
    end
  end

  ### Rake Template Author + Updates ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  #                                                                                             0101010
  #                                                                                          0010011
  #                                                                                        110101
  #                                                                                      0011
  #     __                  __   ___       __   __    __             ___                          0100010
  #    /  ` |__|  /\  |\ | / _` |__  |    /  \ / _`  |__)  /\  |__/ |__              1010    0010101000001
  #    \__, |  | /~~\ | \| \__> |___ |___ \__/ \__> .|  \ /~~\ |  \ |___           010101110100111101010010
  #                                                                               01     0011000100
  #                                                           2017.01.01   from
  #                                                                                 0100
  #                                                                              01001001
  #                                                                             0100111001    000001010001110
  #                                                                            101       0010010000010100100101
  #                                                                        00111          0010011110100011001010
  #                                                                        0110            10000010100111001000100
  #
  #                                                                                         github.com/binarybabel
  #
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end
