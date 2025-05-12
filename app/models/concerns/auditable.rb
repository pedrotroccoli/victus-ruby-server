module Auditable
  extend ActiveSupport::Concern

  included do
    after_create  :log_create
    after_update  :log_update
    after_destroy :log_destroy
  end

  private

  def log_create
    AuditLog.create!(
      auditable_type: self.class.name,
      auditable_id: self.id,
      action: "create",
      item_changes: self.attributes
    )
  end

  def log_update
    # Mongoid specific: Use attribute_changes instead of changes
    # and check changed? to verify if there are changes
    changes_to_log = self.changes.except("_id", "updated_at", "created_at")
    puts "changes_to_log: #{self.changed?}"
    return if changes_to_log.empty?
    
    AuditLog.create!(
      auditable_type: self.class.name,
      auditable_id: self.id,
      action: "update",
      item_changes: changes_to_log
    )
  end

  def log_destroy
    AuditLog.create!(
      auditable_type: self.class.name,
      auditable_id: self.id,
      action: "destroy",
      item_changes: self.attributes
    )
  end
end