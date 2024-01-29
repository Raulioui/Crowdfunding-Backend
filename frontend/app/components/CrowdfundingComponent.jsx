"use client"
import Image from 'next/image'
import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import Jazzicon, { jsNumberForAddress } from 'react-jazzicon'
import  crowdfundingAbi  from '../../utils/Crowdfunding.json'
import { useNotification } from '@web3uikit/core';
import { CircularProgress, colors } from '@mui/material'
import VotingComponent from "./VotingComponent"
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import { pink } from '@mui/material/colors';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import Diversity1RoundedIcon from '@mui/icons-material/Diversity1Rounded';
import Modal from '@mui/material/Modal';
import Link from 'next/link'

function CustomTabPanel(props) {
    const { children, value, index } = props;
  
    return (
      <div
        role="tabpanel"
        hidden={value !== index}
        id={`simple-tabpanel-${index}`}
        aria-labelledby={`simple-tab-${index}`}
      >
        {value === index && (
          <Box sx={{ p: 3 }}>
            <Typography>{children}</Typography>
          </Box>
        )}
      </div>
    );
}
  
export default function CrowdfundingComponent({categorie, description, imageCid, name, owner, pair, target, timeLimit, donations, withdraws, votings}) {

    const [amountRaised, setAmountRaised] = useState(0)
    const [conversion, setConversion] = useState(0)
    const [date, setDate] = useState()
    const [donation, setDonation] = useState(0)
    const [donationMessage, setDonationMessage] = useState('')
    const [donationInDol, setDonationInDol] = useState(0)
    const [loading, setLoading] = useState(true)
    const [isCompleted, setIsCompleted] = useState(false)
    const [showModal, setShowModal] = useState(false)
    const [votingMessage, setVotingMessage] = useState('')
    const [_date, _setDate] = useState(null)
    const [percentage, setPercentage] = useState(0)
    const [value, setValue] = useState(0);

    const dispatch = useNotification()

    const requestOptions = {
        method: 'GET',
        redirect: 'follow'
    }

    const handleChange = (event, newValue) => {
      setValue(newValue);
    };

    useEffect(() => {

        fetch("https://api.coincap.io/v2/assets/ethereum", requestOptions)
        .then(res => res.json())
        .then(dat => setConversion(dat?.data.priceUsd))

        const amount = donations?.reduce((total, item) => {
            return total + Number(item?.args[2])
        }, 0)

        const amountWithdrawed = withdraws?.reduce((total, item) => {
            return total + Number(item?.args[1])
        }, 0)

        const amountWithdrawedInEther = ethers.utils.formatUnits(amountWithdrawed.toString(), "gwei")
        const amountInEther = ethers.utils.formatUnits(amount.toString(), "gwei")

        setAmountRaised(Number(amountInEther) - Number(amountWithdrawedInEther))
        const date = new Date(timeLimit * 1000)
        setDate(date.toDateString())
        const perc = Math.trunc((Number(amountRaised) / Number(target)) * 100)
        setPercentage(perc.toString())
        setLoading(false)
    },[amountRaised, donations])

    async function donate(e) {
        e.preventDefault()
        setLoading(true)
        const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
       
  
 		const contractInstance = new ethers.Contract (
		  pair, crowdfundingAbi, signer
		);
		
	 	const tx = await contractInstance.donate(donationMessage, {gasLimit: 1000000, value: ethers.utils.parseUnits(donation.toString(), "gwei")})
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Donation completed",
				title: "Created",
				position: "topR",
			})

		} else {
            setLoading(false)
			throw new Error("Failed donating")
		}
        setLoading(false)
        setDonation(0)
        setDonationInDol(0)
    }

    async function withdraw() {
        setLoading(true)
        const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
  
 		const contractInstance = new ethers.Contract (
		  pair, crowdfundingAbi, signer
		);
		
	 	const tx = await contractInstance.withdrawUser()
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Withdraw completed",
				title: "Created",
				position: "topR",
			})
            setIsCompleted(true)

		} else {
			throw new Error("Failed withdrawing")
		}
        setLoading(false)
    }

    async function createVoting() {
        setLoading(true)
        const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();

   		const contractInstance = new ethers.Contract (
		  pair, crowdfundingAbi, signer
		);
		
	 	const tx = await contractInstance.createVoting(votingMessage)
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Withdraw completed",
				title: "Created",
				position: "topR",
			})

		} else {
			throw new Error("Failed creating the crowdfunding")
		}
        setLoading(false)
    }
    
    async function withdrawOwner() {
        setLoading(true)
        const provider = new ethers.providers.Web3Provider(window.ethereum);
		await provider.send("eth_requestAccounts", []);
		const signer = provider.getSigner();
  
 		const contractInstance = new ethers.Contract (
		  pair, crowdfundingAbi, signer
		);
		
	 	const tx = await contractInstance.withdrawOwner()
		await tx.wait(1)
		if(tx) {
			dispatch({
				type: "success",
				message: "Voting created",
				title: "Created",
				position: "topR",
			})

		} else {
			throw new Error("Failed creating the crowdfunding")
		}
		console.log(tx) 
        setLoading(false)
    }

    return(
        <div>
            {loading ? (
                <div className="flex items-center justify-center mt-[300px]">
                     <CircularProgress color="secondary" size={60}/>
                 </div>
            ) : (
                <div>
                    {isCompleted ? (
                        <p>This crowdfunding is completed</p>
                    ) : (
                        <section className="w-[95%]  p-8 text-[#333333] m-auto md:w-[80%] xl:w-[60%]">
                        
                        <div className="text-center">
                            <Link href="/">
                                <Diversity1RoundedIcon 
                                    sx={{ fontSize: 60, color: pink[300] }}
                                />
                            </Link>
                        </div>

                        <Box sx={{ borderBottom: 1, borderColor: 'divider'}}>
                            <Tabs sx={{color: "black"}} value={value} onChange={handleChange} aria-label="basic tabs example">
                                <Tab  label="Campaing"  />
                                <Tab label="Votings"  />
                            </Tabs>
                        </Box>

                        <CustomTabPanel value={value} index={0} >
                        <div className='xl:flex xl:justify-start'>
                                <div className=''>
                                    <h1 className='font-bold text-4xl mb-8'>{name}</h1>
                                    <Image 
                                        src={`https://ipfs.io/ipfs/${imageCid}`}
                                        fill={false}
                                        height={500}
                                        width={600}
                                        alt={name}
                                        className="rounded-lg m-auto"
                                    />
                                </div>

                                <div className='xl:fixed top-10 right-6 xl:right-10 xl:w-[20%]'>
                                    <div>
                                        <p>{amountRaised.toFixed(4)} raised of {Number(target).toFixed(4)} ethers ({percentage}%)</p>
                                        <div className='w-full h-[14px]  mt-4 border-2 rounded-full bg-gray-400'>
                                            <div className={`w-[${percentage}%] bg-[#02A95C] h-full rounded-full `}></div>
                                            
                                        </div>
                                        
                                    </div>
                                    <form className='text-center' onSubmit={donate}>
                                        <div>
                                            <input 
                                                type="text" 
                                                placeholder="Amount" 
                                                required 
                                                className='w-full h-10 border-2 border-[#FF80AC] rounded-lg mt-8 mb-4 p-2' 
                                                onChange={(e) => {
                                                    setDonationInDol(e.target.value * conversion)
                                                    setDonation(Number(e.target.value))
                                                }}
                                            />
                                            <p>{donationInDol.toFixed(2)} $</p>
                                        </div>
                                        <input type="text" onChange={(e) => setDonationMessage(e.target.value)} placeholder="Message" required className='w-full h-10 border-2 border-[#FF80AC] rounded-lg mt-8 mb-4 p-2'/>
                                        <button type="submit" className='w-full m-auto h-10 bg-[#FF80AC] rounded-lg font-bold text-white mt-4 max-w-[300px]'>Donate</button>
                                        <button onClick={withdraw} type="button" className='w-full  mt-4 h-10 bg-[#FF80AC] font-bold rounded-lg max-w-[300px] text-white'>Withdraw</button>
                                    </form>
                                   
                                </div>
                            </div>

                            <div className='flex flex-col items-center md:flex-row gap-8 mt-12'>
                                <p>{<Jazzicon diameter={50} seed={jsNumberForAddress(owner)} />}</p>
                                <p>Owner: {owner} VIEW ON ETHERSCAN</p>
                            </div>

                            <p className='mt-8'>Finish date: {date}</p>

                            <div className='mt-8 leading-loose max-w-[600px]'>
                                <p>{description}</p>
                            </div>

                            <div>
                                <h3 className='font-bold text-left  my-14 text-4xl'>Donations ({donations.length})</h3>
                            </div>

                            <div className=''>
                                {donations?.map((d) => {
                                    return(
                                        <div key={d?.args[1]} className='flex-col md:flex-row md:flex  gap-8 mb-14 text-center'>
                                            <Jazzicon diameter={50} seed={jsNumberForAddress(d?.args[0])} />
                                            <div className='flex flex-col gap-2 text-center'>
                                                <p>{d?.args[0]} donate {Number(d?.args[2]) / 1000000000} ethers</p>
                                                <p>{d?.args[1]}</p>
                                            </div>
                                        </div>
                                    )
                                })}
                            </div>

                            <button onClick={withdrawOwner}>
                                Withdraw (Owner)
                            </button>

                            <button onClick={() => setShowModal(true)}>
                                Create voting (Owner)
                            </button>
                        </CustomTabPanel>
                        <CustomTabPanel value={value} index={1}>
                            <div>
                                <div className='flex items-center gap-2 mb-2'>
                                    <div className='w-[15px] h-[15px]  bg-green-600'></div>
                                    <p>Yes votes</p>
                                </div>
                                <div className='flex items-center gap-2'>
                                    <div className='w-[15px] h-[15px] bg-red-700'></div>
                                    <p>No Votes</p>
                                </div>
                               
                            </div>
                            <div>

                                {votings?.length == 0 ? (
                                    <p className='text-xl text-center mt-12 font-bold'>There're no current votings</p>
                                ) : (
                                    <div>
                                    {votings?.map((v) => {
                                        return (
                                            <VotingComponent 
                                                key={v?.args[2]}
                                                owner={v?.args[0]}
                                                pair={v?.args[2]}
                                                message={v?.args[1]}
                                                crowdfundingContract={pair}
                                                timeLimit={v?.args[3]}
                                            />
                                        )
                                    })}
                                    </div>
                                )}
                            </div>
                        </CustomTabPanel>

                            
                        </section>

                    )}

                    <Modal
                    open={showModal}
                    onClose={() => setShowModal(false)}
                    aria-labelledby="modal-modal-title"
                    aria-describedby="modal-modal-description"
                    >
                    <Box className="flex flex-col ">
                        <textarea 
                                onChange={(e) => setVotingMessage(e.target.value)}
                                className='max-w-[700px] sm:w-[60%] w-full m-auto overflow-auto mt-[300px] bg-white text-center  rounded-full p-8 resize-none shadow-sm shadow-black' 
                                placeholder='Title of the voting'
                                required
                        />
                        <button onClick={createVoting} className='m-auto w-[150px] font-bold shadow-sm shadow-black h-10 bg-[#FF80AC] rounded-lg text-white mt-4'>Create voting</button>

                    </Box>
                    </Modal>

                </div>
            )}
        </div>
    )
}

