export default async function CrowdfundingCard({fileCid, name, numberOfDonations, totalRaised}) {
    const res = await getCrowdfundings("bafkreif23354fg4kwwqq4vapi4gxj7rtsqwomamu46heaei4ti7bklfnfy")
    
    console.log(res)

    return(
        <div className=" hover:scale-105 duration-300">
            <Link href={`/crowdfunding/${pair}`} scroll={false}>
                <div className="w-[250px]">
                    <div className="w-[250px] h-[200px] relative ">
                        <Image 
                            src={`https://ipfs.io/ipfs/${fileCid}`}
                            fill={true}
                            alt={name}
                            className="rounded-lg"
                        />
                    </div>
                    <div>
                        <h2 className="font-bold my-2 text-lg">{name}</h2>
                    </div>
                </div>
            </Link>
        </div>  
    )
}