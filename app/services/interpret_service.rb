require 'xa/registry/client'
require 'xa/rules/context'
require 'xa/rules/interpret'
require 'xa/transforms/interpret'
require 'xa/util/documents'

class InterpretService
  class Documents
    include XA::Util::Documents
  end
  
  class RuleInterpreter
    include XA::Rules::Interpret
  end

  class TransformInterpreter
    include XA::Transforms::Interpret
  end
  
  def self.execute(invoice_id, rule_id, transform_id)
    get_latest_invoice_revision(invoice_id) do |doc|
      download_rule(rule_id) do |rule|
        build_tables_from_transform(doc, transform_id) do |tables|
          ctx = XA::Rules::Context.new(tables)

          tables = ctx.execute(rule).tables
          reverse_transform_and_merge(transform_id, doc, tables) do |content|
            Revision.create(invoice_id: invoice_id, document: Document.create(content: content))
          end
        end
      end
    end
  end

  private

  def self.get_latest_invoice_revision(invoice_id)
    im = Invoice.find(invoice_id)
    yield(im.revisions.last.document.content) if im.revisions.length > 0

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("! failed to find invoice (id=#{invoice_id})")
  end
  
  def self.download_rule(rule_id)
    rm = Rule.find(rule_id)
    cl = XA::Registry::Client.new(Rails.configuration.xa['registry']['url'])
    rule_content = cl.rule_by_full_reference(rm.reference)

    yield(RuleInterpreter.new.interpret(rule_content))

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("! failed to find rule (id=#{rule_id})")
  end

  def self.build_tables_from_transform(document, transform_id)
    txm = Transformation.find(transform_id)
    shared_content = document.except('lines')
    document_table = document.fetch('lines', []).map do |ln|
      shared_content.merge(ln)
    end
    yield(TransformInterpreter.new.interpret(document_table, txm.content['tables']))
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("! failed to find transformation (id=#{transform_id})")    
  end

  def self.reverse_transform_and_merge(transform_id, doc, tables)
    docs = Documents.new
    txm = Transformation.find(transform_id)
    all_content = TransformInterpreter.new.misinterpret(tables, txm.content['tables'])
  # search through all_content to determine fields that should appear in shared_content
    shared_content = all_content.inject({}) do |sc, d|
      it_shared_content = d.keys.inject({}) do |itsc, k|
        docs.document_contains_path(doc, k) ? docs.combine_documents([itsc, { k => d[k] }]) : itsc
      end
      docs.combine_documents([sc, it_shared_content])
    end

 # search through and find all lines content
    lines_content = all_content.map do |d|
      d.keys.inject({}) do |lc, k|
        !docs.document_contains_path(doc, k) ? lc.merge(k => d[k]) : lc
      end
    end

    # create a new document
    yield(docs.combine_documents([doc, shared_content.merge('lines' => lines_content)]))
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("! failed to find transformation (id=#{transform_id})")        
  end
end