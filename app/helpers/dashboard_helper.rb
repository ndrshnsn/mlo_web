module DashboardHelper
  def translateTM(taction, all = nil)
		tvalues = {
			  "dismiss" => ["ri-close-line", "Demissão"],
			  "hire" => ["ri-shopping-cart-line", "Contratação"],
			  "steal" => ["ri-flashlight-line", "Roubo"]
			 }

		if all == true
			return tvalues
		else
			return tvalues[taction]
		end
	end
end
