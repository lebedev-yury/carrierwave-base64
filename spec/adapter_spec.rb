RSpec.describe Carrierwave::Base64::Adapter do
  describe '.mount_base64_uploader' do
    let(:uploader) { Class.new CarrierWave::Uploader::Base }

    subject do
      User.mount_base64_uploader(
        :image, uploader, file_name: ->(u) { u.username }
      )
      User.new(username: 'batman')
    end

    let(:mongoid_model) do
      MongoidModel.mount_base64_uploader(:image, uploader)
      MongoidModel.new
    end

    it 'mounts the uploader on the image field' do
      expect(subject.image).to be_an_instance_of(uploader)
    end

    context 'normal file uploads' do
      before(:each) do
        sham_rack_app = ShamRack.at('www.example.com').stub
        sham_rack_app.register_resource(
          '/test.jpg', file_path('fixtures', 'test.jpg'), 'images/jpg'
        )
        subject[:image] = 'test.jpg'
      end

      it 'sets will_change for the attribute on activerecord models' do
        expect(subject.changed?).to be_truthy
      end

      it 'saves the file' do
        subject.save!
        subject.reload

        expect(
          subject.image.current_path
        ).to eq file_path('../uploads', 'test.jpg')
      end
    end

    context 'base64 strings' do
      before(:each) do
        subject.image = File.read(
          file_path('fixtures', 'base64_image.fixture')
        ).strip
      end

      it 'creates a file' do
        subject.save!
        subject.reload

        expect(
          subject.image.current_path
        ).to eq file_path('../uploads', 'batman.jpeg')
      end

      it 'sets will_change for the attribute' do
        expect(subject.changed?).to be_truthy
      end

      it 'does not call will_change mongoid models' do
        expect do
          mongoid_model.image = 'test.jpg'
        end.not_to raise_error
      end

      context 'with additional instances of the mounting class' do
        let(:another_subject) do
          another_subject = User.new(username: 'robin')
          another_subject.image = File.read(
            file_path('fixtures', 'base64_image.fixture')
          ).strip
          another_subject
        end

        it 'should invoke the file_name proc upon each upload' do
          subject.save!
          another_subject.save!
          another_subject.reload
          expect(
            another_subject.image.current_path
          ).to eq file_path('../uploads', 'robin.jpeg')
        end
      end
    end

    context 'base64 string and filename passed in a hash' do
      before(:each) do
        subject.image = {
          data: File.read(
            file_path('fixtures', 'base64_image.fixture')
          ).strip,
          file_name: 'image.jpeg'
        }
      end

      it 'creates a file' do
        subject.save!
        subject.reload

        expect(
          subject.image.current_path
        ).to eq file_path('../uploads', 'image.jpeg')
      end
    end

    context 'stored uploads exist for the field' do
      before :each do
        subject.image = File.read(
          file_path('fixtures', 'base64_image.fixture')
        ).strip
        subject.save!
        subject.reload
      end

      it 'keeps the file when setting the attribute to existing value' do
        expect(File.exist?(subject.reload.image.file.file)).to be_truthy
        subject.update!(image: subject.image.to_s)
        expect(File.exist?(subject.reload.image.file.file)).to be_truthy
      end

      it 'removes files when remove_* is set to true' do
        subject.remove_image = true
        subject.save!
        expect(subject.reload.image.file).to be_nil
      end
    end
  end
end
