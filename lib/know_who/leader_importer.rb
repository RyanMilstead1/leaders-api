require 'csv'

module KnowWho
  class LeaderImporter
    def import_files(list)
      Leader.transaction do
        begin_import
        list.each do |file|
          prepare_file(file)
          CSV.foreach(
            importing_file,
            headers: true,
            header_converters: :symbol
          ) do |member|
            leader = import_leader(member)
            puts "Imported #{leader.prefix_name}"
          end
          `rm #{importing_file}`
        end
        finish_import
      end
    end

    def begin_import
      Leader.update_all(member_status: 'pending')
    end

    def import_leader(data)
      Leader.create_or_update(data).tap do |leader|
        leader.update_attribute(:member_status, 'current')
      end
    end

    def finish_import
      Leader.update_all({member_status: 'former'}, member_status: 'pending')
    end

    private

    def prepare_file(file)
      puts "converting to UTF8"
      `cp #{file} #{converting_file}`
      `iconv --verbose -c --to-code UTF8//TRANSLIT --output #{importing_file} #{converting_file}`
      `rm #{converting_file}`
    end

    def converting_file
      '/tmp/_converting_to_utf8.csv'
    end

    def importing_file
      '/tmp/importing_leaders.csv'
    end
  end
end
