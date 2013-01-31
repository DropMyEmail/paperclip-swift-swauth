require 'spec_helper'

describe 'SwiftSwauth' do
  let(:store) { Dummy.new }

  describe '#exists?' do
    subject     { store.exists?(style) }
    let(:style) { 'square' }

    context 'when attachment with default style exists' do
      before { Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?) { true } }
      it { should be_true }
    end

    context 'when attachment with defined style exists' do
      before { Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(style) { true } }
      it { should be_true }
    end

    context 'when attachment with default style does not exist' do
      before { Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?) { false } }
      it { should be_false }
    end

    context 'when attachment with defined style does not exist' do
      before { Paperclip::Swift::SwauthClient.any_instance.should_receive(:object_exists?).with(style) { false } }
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

    context 'when delete queue has items'
    context 'when delete queue has no items'
  end

  describe '#copy_to_local_file' do
    subject { store.copy_to_local_file(style, local_dest_path) }

    context 'when file exists'
    context 'when file does not exist'
  end
end
