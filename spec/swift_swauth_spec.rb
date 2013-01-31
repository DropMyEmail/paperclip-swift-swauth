require 'spec_helper'

describe 'SwiftSwauth' do
  let(:store) { Dummy.new }

  describe '#exists?' do
    let(:defined_style) { 'circle' }
    let(:default_style) { 'square' }

    context 'when attachment with default style exists' do
      subject { store.exists? }
      let(:default_path) { '/path/to/square' }

      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(default_path) { true }
        store.should_receive(:path).with(default_style) { default_path }
        store.stub(:default_style) { default_style }
      end

      it { should be_true }
    end

    context 'when attachment with defined style exists' do
      subject { store.exists?(defined_style) }
      let(:defined_path) { '/path/to/circle' }

      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(defined_path) { true }
        store.should_receive(:path).with(defined_style) { defined_path }
      end

      it { should be_true }
    end

    context 'when attachment with default style does not exist' do
      subject { store.exists? }
      let(:default_path) { '/path/to/square' }

      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(default_path) { false }
        store.should_receive(:path).with(default_style) { default_path }
        store.stub(:default_style) { default_style }
      end

      it { should be_false }
    end

    context 'when attachment with defined style does not exist' do
      subject { store.exists?(defined_style) }
      let(:defined_path) { '/path/to/circle' }

      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(defined_path) { false }
        store.should_receive(:path).with(defined_style) { defined_path }
      end

      it { should be_false }
    end
  end

  describe '#flush_writes' do
    subject            { store.flush_writes }
    let(:opt_value)    { 'moo' }
    let(:opts)         { { content_type: opt_value } }
    let(:foo_obj_path) { 'foo' }
    let(:foo_obj)      { double('foo_obj') }
    let(:foo_style)    { 'foo' }
    let(:moo_obj_path) { 'moo' }
    let(:moo_obj)      { double('moo_obj') }
    let(:moo_style)    { 'moo' }

    context 'when write queue has an item' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:create_object).with(foo_obj_path, opts, foo_obj) { true }
        store.stub(:after_flush_writes)
        store.stub(:path) { foo_obj_path }
        store.stub(:instance_read) { opt_value }
        store.queued_for_write = { foo_style => foo_obj }
      end

      it 'should write to the store' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when write queue has many items' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:create_object).with(foo_obj_path, opts, foo_obj) { true }
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:create_object).with(moo_obj_path, opts, moo_obj) { true }
        store.stub(:after_flush_writes)
        store.should_receive(:path).with(foo_style) { foo_obj_path }
        store.should_receive(:path).with(moo_style) { moo_obj_path }
        store.stub(:instance_read) { opt_value }
        store.queued_for_write = { foo_style => foo_obj, moo_style => moo_obj }
      end

      it 'should write to the store' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when write queue has no items' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_not_receive(:create_object)
        store.stub(:after_flush_writes)
        store.queued_for_write = {}
      end

      it 'should not write to the store' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#flush_deletes' do
    subject { store.flush_deletes }
    let(:foo_path) { 'foo path' }
    let(:bar_path) { 'bar path' }

    context 'when delete queue has a single item' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:delete_object).with(foo_path)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(foo_path) { true }
        store.queued_for_delete = [foo_path]
      end

      it 'should remove the object' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when delete queue has a few items' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:delete_object).with(foo_path)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(foo_path) { true }
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:delete_object).with(bar_path)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(bar_path) { true }
        store.queued_for_delete = [foo_path, bar_path]
      end

      it 'should remove the objects' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when delete queue has non existent items' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:delete_object).with(foo_path)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(foo_path) { true }
        Paperclip::Swift::SwauthClient.any_instance.should_not_receive(:delete_object).with(bar_path)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(bar_path) { false }
        store.queued_for_delete = [foo_path, bar_path]
      end

      it 'should remove the objects' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when delete queue has no items' do
      before do
        Paperclip::Swift::SwauthClient.any_instance.should_not_receive(:delete_object)
        store.queued_for_delete = []
      end

      it 'should not remove any objects' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#copy_to_local_file' do
    subject { store.copy_to_local_file(defined_style, local_dest_path) }
    let(:defined_style) { 'trapezium' }
    let(:local_dest_path) { '/path/to/file' }
    let(:mock_file) { double('file') }
    let(:mock_obj) { double('obj') }

    context 'when file exists' do
      before do
        mock_file.should_receive(:write)
        mock_file.should_receive(:close)
        File.should_receive(:open).with(local_dest_path, 'wb') { mock_file }
        store.should_receive(:exists?) { true }
        store.should_receive(:path).with(defined_style)
        mock_obj.should_receive(:data)
        Paperclip::Swift::SwauthClient.any_instance.should_receive(:object) { mock_obj }
      end

      it 'should write the file locally' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when file does not exist' do
      before do
        mock_file.should_not_receive(:write)
        mock_file.should_not_receive(:close)
        File.should_not_receive(:open).with(local_dest_path, 'wb') { mock_file }
        store.should_receive(:exists?) { false }
        store.should_not_receive(:path).with(defined_style)
        mock_obj.should_not_receive(:data)
        Paperclip::Swift::SwauthClient.any_instance.should_not_receive(:object) { mock_obj }
      end

      it 'should write the file locally' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
