require 'spec_helper'

describe 'SwiftSwauth' do
  let(:store) { Dummy.new }

  describe '#exists?' do
    subject { store.exists?(style) }
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
    subject { store.flush_writes }

    context 'when write queue has items'
    context 'when write queue has no items'
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
