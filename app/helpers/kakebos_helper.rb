module KakebosHelper
  RAILS_ROOT = Rails.root.to_s
  IMAGE_PATH = RAILS_ROOT + "/app/assets/images/"

  def register_data(kakebo_params)
    begin
      upload_file = kakebo_params[:scan]
      regist_params = {}
      regist_params = kakebo_params
      name = upload_file.original_filename
      size = upload_file.size
      regist_params[:scan] =  IMAGE_PATH + name
    rescue
      @kakebo = Kakebo.new(kakebo_params)
      if @kakebo.save
        flash[:success] = "登録が正常に完了しました"
        redirect_to new_kakebo_path
      else
        render action: 'new'
      end
      return
    end
    if file_ok?(name, size)
      redirect_to new_kakebo_path
    else
      File.open(regist_params[:scan], "wb") {|f| f.write(upload_file.read)}
      @kakebo = Kakebo.new(regist_params)
      if @kakebo.save
        flash[:success] = "登録が正常に完了しました"
        redirect_to new_kakebo_path
      else
        render action: 'new'
      end
    end
  end

  def update_data(kakebo_params)
    @kakebo = Kakebo.find(params[:id])
    begin
      if kakebo_params[:scan]
        upload_file = kakebo_params[:scan]
      elsif @kakebo.scan
        upload_file = @kakebo.scan
      end
      regist_params = {}
      regist_params = kakebo_params
      name = upload_file.original_filename
      regist_params[:scan] = IMAGE_PATH + name
    rescue
      if @kakebo.update_attributes(regist_params)
        flash[:success] = "更新が完了しました"
        redirect_to @kakebo
      else
        render action: 'edit'
      end
      return
    end
    if file_ok?(name, size)
      redirect_to edit_kakebo_path(@kakebo)
    else
      File.open(regist_params[:scan], "wb") {|f| f.write(upload_file.read)}
      if @kakebo.update_attributes(regist_params)
        flash[:success] = "更新が完了しました"
        redirect_to @kakebo
      else
        render action: 'edit'
      end
    end
  end

  private

    def kakebo_params
      params.require(:kakebo).permit(:date, :komoku, :shunyu, :shishutsu,
                                     :kind, :scan,   :scanfile, :bikou)
    end

    def file_ok?(filename, filesize)
      if !['.jpg', '.png', '.gif'].include?(File.extname(filename).downcase)
        flash[:error] = 'jpg, png, gifのみアップロードできます'
        return false
      end
      if filesize > 5.megabyte
        flash[:error] = 'アップロードできるファイルのサイズは5MBまでです'
        return false
      end
    end

end
