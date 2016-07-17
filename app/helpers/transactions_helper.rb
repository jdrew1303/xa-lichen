require 'registry/client'

module TransactionsHelper
  def format_transaction_date(t)
    t.updated_at.to_s(:long)
  end

  def transaction_status_as_label(t)
    @status_labels ||= {
      Transaction::STATUS_OPEN   => '.status.open',
      Transaction::STATUS_CLOSED => '.status.closed',
    }
    @status_labels.fetch(t.status, '.status.unknown')
  end

  def transaction_panel_style(t)
    @styles ||= {
      Transaction::STATUS_OPEN   => 'panel-success',
      Transaction::STATUS_CLOSED => 'panel-info',
    }
    @styles.fetch(t.status, 'panel-primary')
  end

  def options_available_rules
    available_rules.map do |name, o|
      [name, o['id']]
    end
  end

  def available_rules
    # @registry_client ||= Registry::Client.new
    # @registry_client.rules
    []
  end
end
