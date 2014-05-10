class KnowWhoImporter
  attr_accessor :state, :leader, :data

  def begin_import
    Leader.update_all(member_status: 'pending')
  end

  def import_leader(data)
    Leader.create_or_update(data)
  end

  def finish_import
    Leader.update_all({member_status: 'former'}, member_status: 'pending')
  end



  # TODO: remove
  def create_or_update(data)
    import_leader(data)
  end
end
