import Header from "../app/components/Header"
import HomeButton from "./components/HomeButton";
import ContractsData from "../app/components/ContractsData";

export default function Home() {

  return(
    <div class="bg-my_bg_image bg-cover bg-center h-[90vh]">
		<Header />
		
		<HomeButton />

		<div className="mt-[380px] p-10">
			<h2 className="text-2xl font-bold mb-8">Recent crowdfundings</h2>
			<ContractsData />
		</div>
    </div>
	)

}